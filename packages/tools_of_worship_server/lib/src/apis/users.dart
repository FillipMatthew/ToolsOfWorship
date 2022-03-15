import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

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

    return router;
  }

  Future<Response> _authenticate(Request request) async {
    print('ApiUsers: _authenticate');

    final payload = await request.readAsString();

    User? user;

    try {
      dynamic userData = json.decode(payload);

      user = await _signIn(
          userData['signInType'], userData['accountId'], userData['password']);
    } on FormatException catch (_) {
      return Response.forbidden('Invalid authentication data.');
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

  Future<User?> _signIn(
      int? signInType, String? accountId, String? password) async {
    if (signInType == null || accountId == null) {
      return null;
    }

    if (signInType == SignInType.localUser && password == null) {
      return null;
    }

    if (signInType == SignInType.localUser) {
    } else if (signInType == SignInType.googleSignIn) {
      String? googleSignInId = await GoogleSignIn.authenticateToken(accountId);
      if (googleSignInId == null) {
        return null;
      }

      Map<String, dynamic>? accountData =
          await _userConnectionsCollection.findOne(where
              .eq('signInType', signInType)
              .and(where.eq('accountId', googleSignInId)));

      if (accountData == null || accountData['userId'] == null) {
        // The user does not yet exist so create it.
        String userId = Xid.string();

        WriteResult result = await _userConnectionsCollection.insertOne({
          'userId': userId,
          'signInType': signInType,
          'accountId': googleSignInId,
          'password': password,
        });

        if (!result.isSuccess) {
          print('Failed to insert user connection into database.');
          return null;
        }

        result = await _usersCollection.insertOne({
          'id': userId,
          'displayName': '',
        });

        if (!result.isSuccess) {
          print('Failed to insert user into database.');
          await _userConnectionsCollection.remove(where.eq('userId', userId));
          return null;
        }

        var userData = await _usersCollection.findOne(where.eq('id', userId));
        if (userData == null) {
          return null;
        }

        return User.fromJson(userData);
      }

      var userData =
          await _usersCollection.findOne(where.eq('id', accountData['userId']));

      if (userData == null) {
        return null;
      }

      return User.fromJson(userData);
    }

    return null;
  }
}
