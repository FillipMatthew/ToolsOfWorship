import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tools_of_worship_client/apis/types/post.dart';

import 'package:tools_of_worship_client/config/properties.dart';
import 'package:tools_of_worship_client/helpers/account_authentication.dart';

class ApiFeed {
  static Stream<Post> getList(
      {int? limit, String? before, String? after}) async* {
    Map<String, dynamic> data = {};
    if (limit != null) {
      data['limit'] = limit;
    }

    if (before != null && DateTime.tryParse(before) != null) {
      data['before'] = before;
    }

    if (after != null && DateTime.tryParse(after) != null) {
      data['after'] = after;
    }

    final http.Response response = await http.post(
      Uri.parse('${Properties.apiHost}/apis/Feed/List'),
      headers: {
        HttpHeaders.authorizationHeader: AccountAuthentication.authHeaderString,
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
      },
      body: json.encode(data),
    );

    if (response.statusCode == HttpStatus.ok) {
      List<Map<String, dynamic>> jsonData = json.decode(response.body);
      for (Map<String, dynamic> item in jsonData) {
        try {
          yield Post.fromJson(item);
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

  static Future<void> postPost(
      String fellowshipId, String heading, String article) async {
    if (fellowshipId.isEmpty || heading.isEmpty || article.isEmpty) {
      throw Exception('Invalid data');
    }

    Map<String, dynamic> data = {
      'fellowshipId': fellowshipId,
      'heading': heading,
      'article': article,
    };

    final http.Response response = await http.post(
      Uri.parse('${Properties.apiHost}/apis/Feed/Post'),
      headers: {
        HttpHeaders.authorizationHeader: AccountAuthentication.authHeaderString,
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
      },
      body: json.encode(data),
    );

    if (response.statusCode == HttpStatus.ok) {
      return;
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw Exception('Unauthorised');
    }

    throw Exception('Unexpected error');
  }
}
