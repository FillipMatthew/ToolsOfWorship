import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:encrypt/encrypt.dart';
import 'package:shelf/shelf.dart';

import 'package:tools_of_worship_server/properties.dart';

class AccountAuthentication {
  static final _tokenKey = Key.fromSecureRandom(32);
  static final _tokenIv = IV.fromSecureRandom(16);

  static String hashPassword(String password, [String? salt]) {
    if (salt == null) {
      final random = Random.secure();
      var values = List<int>.generate(32, (i) => random.nextInt(256));
      salt = base64.encode(values);
    }

    final saltedPassword = salt + password;
    final bytes = utf8.encode(saltedPassword);
    final hash = sha256.convert(bytes);
    return '$salt.$hash';
  }

  static bool validatePassword(String password, String saltHash) {
    final parts = saltHash.split('.');
    if (parts.length != 2) {
      print('saltHash invalid.');
      return false;
    }

    String salt = parts[0];

    final newHash = hashPassword(password, salt);
    return saltHash == newHash;
  }

  static String signToken(String subject, [Duration? duration]) {
    final jwt = JWT(
      {
        'iat': DateTime.now().millisecondsSinceEpoch,
      },
      issuer: 'https://${Properties.domain}',
      subject: subject,
    );

    String token = jwt.sign(
      SecretKey(Properties.jwtSecret),
      expiresIn: duration ?? Duration(hours: 12),
    );

    print('Signed token: $token\n');

    return token;
  }

  static String? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(Properties.jwtSecret));

      print('Payload: ${jwt.payload}');
      return jwt.subject;
    } on JWTExpiredError {
      print('JWT expired.');
    } on JWTError catch (ex) {
      print(ex.message); // Invalid signature
    } on FormatException catch (_) {
      print('Invalid token.');
    }

    return null;
  }

  static String encryptToken(String token) {
    final encrypter = Encrypter(AES(_tokenKey, mode: AESMode.cbc));
    final data = encrypter.encrypt(token, iv: _tokenIv);
    return data.base64;
  }

  static String decryptToken(String token) {
    final encrypter = Encrypter(AES(_tokenKey, mode: AESMode.cbc));
    final data = encrypter.decrypt64(token, iv: _tokenIv);
    return data;
  }

  static Middleware checkAuthorisation() {
    return createMiddleware(
      requestHandler: (Request request) {
        if (request.url.path != 'Users/Authenticate' &&
            request.url.path != 'Users/Signup' &&
            request.url.path != 'Users/VerifyEmail' &&
            request.context['authDetails'] == null) {
          return Response.forbidden('Unauthorised.');
        }

        return null;
      },
    );
  }

  static Middleware handleAuth() {
    return (Handler innerHandler) {
      return (Request request) async {
        final updatedRequest = request.change(
          context: {
            'authDetails': _authenticateRequest(request),
          },
        );

        return await innerHandler(updatedRequest);
      };
    };
  }

  // Returns the authenticated token subject if the request is authorised.
  static String? _authenticateRequest(Request request) {
    print('_authenticate request.');
    String? authHeader = request.headers[HttpHeaders.authorizationHeader];
    if (authHeader == null) {
      return null;
    }

    return _isAuthorized(authHeader);
  }

  static String? _isAuthorized(String authHeader) {
    final parts = authHeader.split(' ');
    if (parts.length != 2 || parts[0] != 'Bearer') {
      return null;
    }

    return verifyToken(parts[1]);
  }
}
