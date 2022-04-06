import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tools_of_worship_client/apis/types/feed_post.dart';

import 'package:tools_of_worship_client/config/properties.dart';
import 'package:tools_of_worship_client/helpers/account_authentication.dart';

class ApiFeed {
  static Future<List<FeedPost>> getList() async {
    final http.Response response = await http.get(
      Uri.parse('${Properties.apiHost}/apis/Feed/List'),
      headers: {
        HttpHeaders.authorizationHeader: AccountAuthentication.authHeaderString,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      try {
        List<Map<String, dynamic>> data = json.decode(response.body);

        List<FeedPost> feedList = [];
        for (Map<String, dynamic> item in data) {
          try {
            feedList.add(FeedPost.fromJson(item));
          } catch (_) {}
        }

        return feedList;
      } on FormatException catch (_) {
        throw Exception('Invalid data.');
      }
    } else if (response.statusCode == HttpStatus.forbidden) {
      throw Exception('Unauthorised.');
    }

    throw Exception('Unexpected error.');
  }
}
