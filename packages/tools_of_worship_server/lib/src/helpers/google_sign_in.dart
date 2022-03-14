import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart' as basic_utils;
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:convert/convert.dart';

import 'package:tools_of_worship_server/properties.dart';

class GoogleSignIn {
  static final List<String> _googlePublicKeys = <String>[];
  static DateTime _keyExpiration = DateTime.now().toUtc();

  static Future<String?> authenticateToken(String token) async {
    if (_googlePublicKeys.isEmpty || _isExpired()) {
      await _updateGooglePublicKey();
    }

    if (_googlePublicKeys.isEmpty) {
      print('No Google puplic keys to decode with.');
      return null;
    }

    for (String key in _googlePublicKeys) {
      try {
        final jwt = JWT.verify(
          token,
          RSAPublicKey(key),
          //issuer: 'accounts.google.com',
          audience: Audience([Properties.googleSignInClientId]),
        );

        // Manually check the issuer since we have multiple to compare to.
        if (jwt.issuer != 'accounts.google.com' &&
            jwt.issuer != 'https://accounts.google.com') {
          print('Invalid issuer.');
          return null;
        }

        // print('Payload: ${jwt.payload}');
        print('Account validated.');
        return jwt.subject;
      } on JWTExpiredError {
        print('JWT Google sign in token expired.');
      } on JWTError catch (ex) {
        print(ex.message); // Invalid signature
      }
    }

    return null;
  }

  static _updateGooglePublicKey() async {
    bool hasSetExpiration = false;
    _keyExpiration = DateTime.now().toUtc();
    _googlePublicKeys.clear();
    final http.Response response =
        await http.get(Uri.parse('https://www.googleapis.com/oauth2/v1/certs'));
    if (response.statusCode == 200) {
      String? cacheControl = response.headers[HttpHeaders.cacheControlHeader];
      if (cacheControl != null) {
        List<String> parts = cacheControl.split(',');
        for (String part in parts) {
          Match? match = part.matchAsPrefix('max-age=');
          if (match != null) {
            int? maxAgeSeconds = int.tryParse(part.substring(match.end).trim());
            if (maxAgeSeconds != null) {
              _keyExpiration =
                  DateTime.now().toUtc().add(Duration(seconds: maxAgeSeconds));
              hasSetExpiration = true;
            }
          }
        }
      }

      if (!hasSetExpiration) {
        _keyExpiration = DateTime.now().toUtc().add(Duration(minutes: 5));
      }

      try {
        Map<String, dynamic> data = json.decode(response.body);
        for (String key in data.keys) {
          basic_utils.X509CertificateData certData =
              basic_utils.X509Utils.x509CertificateFromPem(data[key]);

          if (certData.publicKeyData.bytes != null) {
            final bytes = hex.decode(certData.publicKeyData.bytes!);
            final rsaKey = basic_utils.CryptoUtils.rsaPublicKeyFromDERBytes(
                Uint8List.fromList(bytes));
            final pem = basic_utils.CryptoUtils.encodeRSAPublicKeyToPem(rsaKey);
            _googlePublicKeys.add(pem);
          }
        }
      } on FormatException catch (_) {
        print('Invalid public key data.');
        _googlePublicKeys.clear();
      }
    }
  }

  static bool _isExpired() {
    if (DateTime.now().toUtc().isAfter(_keyExpiration)) {
      return true;
    } else {
      return false;
    }
  }
}
