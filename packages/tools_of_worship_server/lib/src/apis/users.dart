import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:string_validator/string_validator.dart';
import 'package:tools_of_worship_server/properties.dart';
import 'package:tools_of_worship_server/src/helpers/email_relay.dart';

import 'package:tools_of_worship_server/src/helpers/google_sign_in.dart';
import 'package:tools_of_worship_server/src/types/sign_in_type.dart';
import 'package:tools_of_worship_server/src/types/user.dart';
import 'package:tools_of_worship_server/src/helpers/account_authentication.dart';
import 'package:xid/xid.dart';

class ApiUsers {
  final DbCollection _userConnectionsCollection;
  final DbCollection _usersCollection;

  ApiUsers(DbCollection userConnections, DbCollection users)
      : _userConnectionsCollection = userConnections,
        _usersCollection = users;

  Router get router {
    Router router = Router();

    router.post("/Authenticate", _authenticate);
    router.post("/Signup", _signup);
    router.get("/VerifyEmail/<encryptedToken>", _verifyEmail);

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

  Future<Response> _verifyEmail(Request request, String encryptedToken) async {
    print('ApiUsers: _verifyEmail');

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

      return Response.ok(['Account created.'],
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

      Map<String, dynamic>? accountData =
          await _userConnectionsCollection.findOne(where
              .eq('signInType', signInType)
              .and(where.eq('accountId', accountId)));

      if (accountData == null ||
          accountData['userId'] == null ||
          accountData['authDetails'] == null) {
        return null; // No user found.
      }

      String saltHash = accountData['authDetails'];

      if (!AccountAuthentication.validatePassword(password, saltHash)) {
        return null;
      }

      var userData =
          await _usersCollection.findOne(where.eq('id', accountData['userId']));

      if (userData != null) {
        return User.fromJson(userData);
      }
    } else if (signInType == SignInType.googleSignIn) {
      Map<String, String> signInData =
          await GoogleSignIn.authenticateToken(accountId);
      String? googleSignInId = signInData['userId'];
      String? userDisplayName = signInData['displayName'];
      if (googleSignInId == null || userDisplayName == null) {
        return null;
      }

      Map<String, dynamic>? accountData =
          await _userConnectionsCollection.findOne(where
              .eq('signInType', signInType)
              .and(where.eq('accountId', googleSignInId)));

      if (accountData == null || accountData['userId'] == null) {
        // No user link to this Google account yet. First check if the email is used.
        String? userEmail = signInData['email'];

        if (userEmail != null) {
          userEmail = normalizeEmail(userEmail);
          accountData = await _userConnectionsCollection.findOne(where
              .eq('signInType', SignInType.localUser)
              .and(where.eq('accountId', userEmail)));
        }

        String userId;
        bool bCreatedNewUser = false;
        if (userEmail == null ||
            accountData == null ||
            accountData['userId'] == null) {
          // The user does not yet exist so create it.
          userId = Xid.string();

          WriteResult result = await _usersCollection.insertOne({
            'id': userId,
            'displayName': userDisplayName,
          });

          if (!result.isSuccess) {
            print('Failed to insert user into database.');
            return null;
          }

          bCreatedNewUser = true;
        } else {
          userId = accountData['userId'];
        }

        // Add a connection for login authentication.
        WriteResult result = await _userConnectionsCollection.insertOne({
          'userId': userId,
          'signInType': SignInType.googleSignIn,
          'accountId': googleSignInId,
        });

        if (!result.isSuccess) {
          print('Failed to insert user connection into database.');
          if (bCreatedNewUser) {
            // Remove the created user since we were unable to add a login connection.
            await _usersCollection.remove(where.eq('id', userId));
          }

          return null;
        }

        if (bCreatedNewUser) {
          // If we created a new user then there were no login connections, make sure to create all.

          // Add a connection for email login authentication. A password will still need to be configured.
          // Prevents users from creating a second account with the password linkged to Google.
          WriteResult result = await _userConnectionsCollection.insertOne({
            'userId': userId,
            'signInType': SignInType.localUser,
            'accountId': userEmail,
          });

          if (!result.isSuccess) {
            print('Failed to insert user connection into database.');
            if (bCreatedNewUser) {
              // Remove the created user since we were unable to add all login connections.
              await _usersCollection.remove(where.eq('id', userId));
              await _userConnectionsCollection.remove(where.eq('id', userId));
            }

            return null;
          }
        }

        var userData = await _usersCollection.findOne(where.eq('id', userId));
        if (userData != null) {
          return User.fromJson(userData);
        }

        return null;
      }

      var userData =
          await _usersCollection.findOne(where.eq('id', accountData['userId']));

      if (userData != null) {
        return User.fromJson(userData);
      }
    }

    return null;
  }

  Future<bool> _validateNewUser(String email) async {
    Map<String, dynamic>? accountData =
        await _userConnectionsCollection.findOne(where
            .eq('signInType', SignInType.localUser)
            .and(where.eq('accountId', normalizeEmail(email))));

    if (accountData != null && accountData['userId'] != null) {
      print('Email already in use.');
      return false;
    }

    return true;
  }

  Future<bool> _createNewUser(
      String email, String authDetails, String displayName) async {
    String userId = Xid.string();

    WriteResult result = await _usersCollection.insertOne({
      'id': userId,
      'displayName': displayName,
    });

    if (!result.isSuccess) {
      print('Failed to insert user into database.');
      await _usersCollection.remove(where.eq('id', userId));
      return false;
    }

    // Add a connection for login authentication.
    result = await _userConnectionsCollection.insertOne({
      'userId': userId,
      'signInType': SignInType.localUser,
      'accountId': normalizeEmail(email),
      'authDetails': authDetails,
    });

    if (!result.isSuccess) {
      print('Failed to insert user connection into database.');
      // Remove the created user since we were unable to add all login connections.
      await _usersCollection.remove(where.eq('id', userId));
      await _userConnectionsCollection.remove(where.eq('id', userId));
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

    if (!await EmailRelay.sendNoReplyEmail(email, 'Please verify your email address', content)) {
      return false;
    }

    return true;
  }
}
