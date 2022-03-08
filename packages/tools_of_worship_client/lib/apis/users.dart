import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:tools_of_worship_client/config/properties.dart';

class ApiUsers {
  static Future<String?> authenticate(
      int signInType, String accountIdentifier, String? password) async {
    String body = json.encode({
      'signInType': signInType,
      'accountIdentifier': accountIdentifier,
      'password': password
    });
    final http.Response response = await http.post(
      Uri.parse('${Properties.apiHost}/apis/Users/Authenticate'),
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        // 'Content-Length': '${body.length}'
      },
      body: body,
    );
    if (response.statusCode == 200) {
      try {
        dynamic userData = json.decode(response.body);

        return userData['token'];
      } on FormatException catch (_) {
        throw Exception('Authentication failed: Invalid response.');
      }
    } else {
      return null;
    }
  }
}
