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

    if (response.statusCode == 200) {
      try {
        List<Map<String, dynamic>> data = json.decode(response.body);

        List<FeedPost> feedList = data.map<FeedPost>((item) {
          return FeedPost.fromJson(item);
        }).toList();

        return feedList;
      } on FormatException catch (_) {
        return <FeedPost>[];
      }
    } else {
      throw Exception('Authentication failed.');
    }
  }
}
