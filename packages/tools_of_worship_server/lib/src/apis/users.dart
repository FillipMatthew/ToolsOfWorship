import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:string_validator/string_validator.dart';
import 'package:tools_of_worship_server/properties.dart';
import 'package:tools_of_worship_server/src/helpers/email_relay.dart';

import 'package:tools_of_worship_server/src/helpers/google_sign_in.dart';
import 'package:tools_of_worship_server/src/interfaces/users_data_provider.dart';
import 'package:tools_of_worship_server/src/types/sign_in_type.dart';
import 'package:tools_of_worship_server/src/types/user.dart';
import 'package:tools_of_worship_server/src/helpers/account_authentication.dart';
import 'package:tools_of_worship_server/src/types/user_connection.dart';
import 'package:xid/xid.dart';

class ApiUsers {
  final UsersDataProvider _usersDataProvider;

  ApiUsers(UsersDataProvider usersDataProvider)
      : _usersDataProvider = usersDataProvider;

  Router get router {
    Router router = Router();

    router.post('/Authenticate', _authenticate);
    router.post('/Signup', _signup);
    router.get('/VerifyEmail', _verifyEmail);

    return router;
  }

  Future<Response> _authenticate(Request request) async {
    print('ApiUsers: _authenticate');

    User? user;
    String? authHeader = request.headers[HttpHeaders.authorizationHeader];
    if (authHeader != null) {
      // If we have an authentication header then ignore the request body.
      final parts = authHeader.split(' ');
      if (parts.length != 2 || parts[0] != 'Basic') {
        return Response.forbidden('Invalid authentication data.');
      }

      final String decoded = utf8.decode(base64.decode(parts[1]));
      final parts2 = decoded.split(':');

      user = await _signIn(SignInType.localUser, parts2[0], parts2[1]);
    } else {
      final payload = await request.readAsString();

      try {
        dynamic signinData = json.decode(payload);

        user = await _signIn(signinData['signInType'], signinData['accountId'],
            signinData['password']);
      } on FormatException catch (_) {
        return Response.forbidden('Invalid authentication data.');
      }
    }

    if (user == null) {
      return Response.forbidden('Authentication failed.');
    }

    final String token = AccountAuthentication.signToken(user.id);

    // Send token back to the user
    return Response.ok(
        json.encode({'token': token, 'displayName': user.displayName}),
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType});
  }

  Future<Response> _signup(Request request) async {
    print('ApiUsers: _signup');

    final payload = await request.readAsString();

    try {
      dynamic signupData = json.decode(payload);

      String email = signupData['email'];
      String password = signupData['password'];
      String displayName = signupData['displayName'];

      if (!isEmail(email)) {
        print('Invalid email provided.');
        return Response.forbidden('Invalid email.');
      }

      if (!isLength(displayName, 2)) {
        print('Display name too short.');
        return Response.forbidden('Display name too short.');
      }

      if (!isLength(displayName, 2)) {
        print('Display name too short.');
        return Response.forbidden('Display name too short.');
      }

      if (!isLength(password, 8)) {
        print('Password too short.');
        return Response.forbidden('Password too short.');
      }

      if (!await _validateNewUser(email)) {
        return Response.forbidden(
            'Unable to create user, email already in use.');
      }

      String authDetails = AccountAuthentication.hashPassword(password);

      if (!await _sendVerificationMail(email, authDetails, displayName)) {
        return Response.forbidden('Unable to send verification email.');
      }

      return Response.ok('Pending email verification.',
          headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType});
    } on FormatException catch (_) {
      return Response.forbidden('Invalid authentication data.');
    }
  }

  Future<Response> _verifyEmail(Request request) async {
    print('ApiUsers: _verifyEmail');

    String query = request.url.query;
    List<String> queries = query.split('&');
    if (queries.length != 1) {
      return Response.forbidden('Invalid token.');
    }

    if (!queries[0].startsWith('token=')) {
      return Response.forbidden('Invalid token.');
    }

    String encryptedToken = queries[0].replaceFirst('token=', '');
    String token = AccountAuthentication.decryptToken(encryptedToken);
    String? data = AccountAuthentication.verifyToken(token);
    if (data == null) {
      return Response.forbidden('Invalid token.');
    }

    try {
      dynamic signupData = json.decode(data);

      String email = signupData['email'];
      String authDetails = signupData['authDetails'];
      String displayName = signupData['displayName'];

      if (!isEmail(email)) {
        print('Invalid email provided.');
        return Response.forbidden('Invalid email.');
      }

      if (!isLength(displayName, 2)) {
        print('Display name too short.');
        return Response.forbidden('Display name too short.');
      }

      if (!isLength(displayName, 2)) {
        print('Display name too short.');
        return Response.forbidden('Display name too short.');
      }

      if (!await _validateNewUser(email)) {
        return Response.forbidden(
            'Unable to create user, email already in use.');
      }

      if (!await _createNewUser(email, authDetails, displayName)) {
        print('Failed to create user.');
        return Response.forbidden('Failed to create user.');
      }

      return Response.ok('Account created.',
          headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType});
    } on FormatException catch (_) {
      return Response.forbidden('Invalid signup data.');
    }
  }

  Future<User?> _signIn(
      int? signInType, String? accountId, String? password) async {
    if (signInType == null || accountId == null) {
      return null;
    }

    if (signInType == SignInType.localUser) {
      if (password == null) {
        return null;
      }

      UserConnection? userConnection = await _usersDataProvider
          .getUserConnection(signInType, normalizeEmail(accountId));
      if (userConnection == null ||
          !userConnection.isValid ||
          userConnection.authDetails == null) {
        return null;
      }

      String saltHash = userConnection.authDetails!;

      if (!AccountAuthentication.validatePassword(password, saltHash)) {
        return null;
      }

      return await _usersDataProvider.getUser(userConnection.userId);
    } else if (signInType == SignInType.googleSignIn) {
      Map<String, String> signInData =
          await GoogleSignIn.authenticateToken(accountId);
      String? googleSignInId = signInData['userId'];
      String? userDisplayName = signInData['displayName'];
      if (googleSignInId == null || userDisplayName == null) {
        return null;
      }

      UserConnection? userConnection = await _usersDataProvider
          .getUserConnection(signInType, googleSignInId);
      if (userConnection != null && userConnection.isValid) {
        return _usersDataProvider.getUser(userConnection.userId);
      } else {
        // No user link to this Google account yet. First check if the email is used.
        String? userEmail = signInData['email'];

        if (userEmail != null) {
          userEmail = normalizeEmail(userEmail);
          userConnection = await _usersDataProvider.getUserConnection(
              SignInType.localUser, userEmail);
        }

        String userId;
        bool bCreatedNewUser = false;
        if (userEmail != null &&
            userConnection != null &&
            userConnection.isValid) {
          // The user already has an account linked to the email. Link the Google sign in to that user account.
          userId = userConnection.userId;
        } else {
          // The user does not yet exist so create it.
          userId = Xid.string();
          User? user = await _usersDataProvider
              .insertNewUser(User.create(userId, userDisplayName));
          if (user == null || !user.isValid) {
            return null;
          }

          bCreatedNewUser = true;
        }

        // Add a connection for Google sign in authentication.
        userConnection = await _usersDataProvider.insertUserConnection(
            UserConnection.create(
                userId, SignInType.googleSignIn, googleSignInId, null));
        if (userConnection == null || !userConnection.isValid) {
          if (bCreatedNewUser) {
            // Remove the created user since we were unable to add a login connection.
            _usersDataProvider.removeUser(userId);
          }

          return null;
        }

        if (bCreatedNewUser && userEmail != null) {
          // If we created a new user then there were no login connections, make sure to create all.

          // Add a connection for email login authentication. A password will still need to be configured for it.
          // This prevents users from creating a second account with the same email, one though email sign in and one through Google sign in.
          userConnection = await _usersDataProvider.insertUserConnection(
              UserConnection.create(
                  userId, SignInType.localUser, userEmail, null));
          if (userConnection == null || !userConnection.isValid) {
            if (bCreatedNewUser) {
              // Remove the created user since we were unable to add all login connections.
              _usersDataProvider.removeUser(userId);
            }

            return null;
          }
        }

        return _usersDataProvider.getUser(userId);
      }
    }

    return null;
  }

  Future<bool> _validateNewUser(String email) async {
    return (await _usersDataProvider.getUserConnection(
                SignInType.localUser, email))
            ?.isValid ??
        false;
  }

  Future<bool> _createNewUser(
      String email, String authDetails, String displayName) async {
    String userId = Xid.string();

    User? user = await _usersDataProvider
        .insertNewUser(User.create(userId, displayName));
    if (user == null || !user.isValid) {
      return false;
    }

    // Add a connection for login authentication.
    UserConnection? userConnection =
        await _usersDataProvider.insertUserConnection(UserConnection.create(
            userId, SignInType.localUser, normalizeEmail(email), authDetails));
    if (userConnection == null || !userConnection.isValid) {
      // Remove the created user since we were unable to add all login connections.
      _usersDataProvider.removeUser(userId);
      return false;
    }

    return true;
  }

  Future<bool> _sendVerificationMail(
      String email, String authDetails, String displayName) async {
    Map data = {};
    data['email'] = normalizeEmail(email);
    data['authDetails'] = authDetails;
    data['displayName'] = displayName;

    String jsonData = json.encode(data);
    String token =
        AccountAuthentication.signToken(jsonData, Duration(minutes: 15));
    String encryptedToken = AccountAuthentication.encryptToken(token);

    String content =
        File('${Properties.dataUri}/VerificationEmailTemplate.html')
            .readAsStringSync();
    content = content.replaceAll(RegExp(r'@token'), encryptedToken);

    if (!await EmailRelay.sendNoReplyEmail(
        email, 'Please verify your email address', content)) {
      return false;
    }

    return true;
  }
}
