import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:tools_of_worship_client/config/properties.dart';

class ApiUsers {
  static Future<Map<String, String>> authenticate(
      int signInType, String accountId, String? password) async {
    String body = json.encode({
      'signInType': signInType,
      'accountId': accountId,
      'password': password,
    });

    final http.Response response = await http.post(
      Uri.parse('${Properties.apiHost}/apis/Users/Authenticate'),
      headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType},
      body: body,
    );

    if (response.statusCode == HttpStatus.ok) {
      return json.decode(response.body);
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw Exception('Authentication failed');
    }

    throw Exception('Unexpected error');
  }

  static Future<bool> signup(
      String displayName, String email, String password) async {
    String body = json.encode({
      'email': email,
      'password': password,
      'displayName': displayName,
    });

    final http.Response response = await http.post(
      Uri.parse('${Properties.apiHost}/apis/Users/Signup'),
      headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType},
      body: body,
    );

    if (response.statusCode == HttpStatus.ok) {
      json.decode(response.body);
      return true;
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw Exception(json.decode(response.body).toString());
    }

    return false;
  }
}
