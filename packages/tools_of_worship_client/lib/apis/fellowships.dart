import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tools_of_worship_client/apis/types/fellowship.dart';
import 'package:tools_of_worship_client/config/properties.dart';
import 'package:tools_of_worship_client/helpers/account_authentication.dart';

class ApiFellowships {
  static Stream<Fellowship> getList() async* {
    final http.Response response = await http.post(
      Uri.parse('${Properties.apiHost}/apis/Fellowships/List'),
      headers: {
        HttpHeaders.authorizationHeader: AccountAuthentication.authHeaderString,
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
