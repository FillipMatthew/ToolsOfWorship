import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/properties.dart';
import '../types/fellowship.dart';

class ApiFellowships {
  final String _authToken;

  ApiFellowships(String authToken) : _authToken = authToken;

  Stream<Fellowship> getList() async* {
    final http.Response response = await http.post(
      Uri.parse('${Properties.apiHost}/apis/Fellowships/List'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $_authToken',
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      List<Map<String, dynamic>> jsonData = json.decode(response.body);
      for (Map<String, dynamic> item in jsonData) {
        try {
          yield Fellowship.fromJson(item);
        } catch (_) {
          throw Exception('Invalid response');
        }
      }

      return;
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw Exception('Unauthorised');
    }

    throw Exception('Unexpected error');
  }
}
