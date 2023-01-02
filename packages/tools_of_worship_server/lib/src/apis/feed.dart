import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:tools_of_worship_server/src/interfaces/circles_data_provider.dart';
import 'package:tools_of_worship_server/src/interfaces/fellowships_data_provider.dart';
import 'package:tools_of_worship_server/src/interfaces/feed_data_provider.dart';
import 'package:tools_of_worship_server/src/interfaces/users_data_provider.dart';
import 'package:tools_of_worship_server/src/types/circle.dart';
import 'package:tools_of_worship_server/src/types/fellowship.dart';
import 'package:tools_of_worship_server/src/types/post.dart';
import 'package:tools_of_worship_server/src/types/user.dart';
import 'package:xid/xid.dart';

class ApiFeed {
  final FeedDataProvider _feedProvider;
  final UsersDataProvider _usersProvider;
  final FellowshipsDataProvider _fellowshipsProvider;
  final CirclesDataProvider _circlesProvider;

  ApiFeed(
      FeedDataProvider feedProvider,
      UsersDataProvider usersProvider,
      FellowshipsDataProvider fellowshipsProvider,
      CirclesDataProvider circlesProvider)
      : _feedProvider = feedProvider,
        _usersProvider = usersProvider,
        _fellowshipsProvider = fellowshipsProvider,
        _circlesProvider = circlesProvider;

  Router get router {
    Router router = Router();

    router.post('/List', _postList);

    router.post('/Post', _postPost);
    router.delete('/Post', _deletePost);

    return router;
  }

  Future<Response> _postList(Request request) async {
    print('ApiFeed: _postList');

    String? userId = request.context['authDetails'] as String;

    final payload = await request.readAsString();

    int? limit;
    DateTime? before;
    DateTime? after;

    try {
      dynamic data = json.decode(payload);

      limit = data['limit'];

      String? beforeStr = data['before'];
      if (beforeStr != null) {
        before = DateTime.tryParse(beforeStr);
      }

      String? afterStr = data['after'];
      if (afterStr != null) {
        after = DateTime.tryParse(afterStr);
      }
    } on FormatException catch (_) {
      return Response.forbidden('Invalid request.');
    }

    Map<String, String?> nameCache = {};
    Map<String, String?> fellowshipNamesCache = <String, String>{};
    Map<String, String?> circleNamesCache = <String, String>{};

    List<Map<String, dynamic>> posts = <Map<String, dynamic>>[];

    Stream<Post> postsResults =
        _feedProvider.getPosts(userId, limit, before, after);
    await for (Post item in postsResults) {
      Map<String, dynamic> post = <String, dynamic>{};
      post['id'] = item.id;
      post['heading'] = item.heading;
      if (nameCache.containsKey(item.authorId)) {
        post['author'] = nameCache[item.authorId];
      } else {
        post['author'] =
            nameCache[item.authorId] = await _getUserName(item.authorId);
      }
      post['dateTime'] = item.dateTime.toUtc().toIso8601String();
      post['article'] = item.article;

      String feedName = '';
      if (item.fellowshipId != null) {
        if (fellowshipNamesCache.containsKey(item.fellowshipId)) {
          feedName += fellowshipNamesCache[item.fellowshipId] ?? '';
        } else {
          Fellowship? fellowship =
              await _fellowshipsProvider.getFellowship(item.fellowshipId!);
          String? name = fellowship?.name;
          fellowshipNamesCache[item.fellowshipId!] = fellowship?.name;
          feedName += name ?? '';
        }
      }

      if (item.circleId != null) {
        if (circleNamesCache.containsKey(item.circleId)) {
          feedName += '(${circleNamesCache[item.circleId] ?? ''})';
        } else {
          Circle? circle = await _circlesProvider.getCircle(item.circleId!);
          String? name = circleNamesCache[item.circleId!] = circle?.name;
          feedName += '(${name ?? ''})';
        }
      }

      post['feedName'] = feedName;

      posts.add(post);
    }

    return Response.ok(
      json.encode(posts),
      headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType},
    );
  }

  Future<Response> _postPost(Request request) async {
    print('ApiFeed: _postPost');

    String? userId = request.context['authDetails'] as String;

    final payload = await request.readAsString();

    try {
      dynamic data = json.decode(payload);

      String? fellowshipId = data['fellowshipId'];
      String? circleId = data['circleId'];
      String? heading = data['heading'];
      String? article = data['article'];

      if (heading == null ||
          article == null ||
          heading.isEmpty ||
          article.isEmpty) {
        return Response.forbidden('Invalid request.');
      }

      // If we have a circle ID we don't need a fellowship ID because they are linked.
      Post? post;
      if (circleId != null && circleId.isNotEmpty) {
        post = Post.create(Xid.string(), userId, null, circleId,
            DateTime.now().toUtc(), heading, article);
      } else if (fellowshipId != null && fellowshipId.isNotEmpty) {
        post = Post.create(Xid.string(), userId, fellowshipId, null,
            DateTime.now().toUtc(), heading, article);
      }

      if (post != null) {
        if (await _feedProvider.create(post)) {
          return Response.ok('');
        } else {
          return Response.forbidden('Post failed.');
        }
      }

      return Response.forbidden('Invalid request.');
    } on FormatException catch (_) {
      return Response.forbidden('Invalid request.');
    }
  }

  Future<Response> _deletePost(Request request) async {
    print('ApiFeed: _deletePost');

    //String? userId = request.context['authDetails'] as String;

    return Response.internalServerError();
  }

  Future<String?> _getUserName(String id) async {
    User? user = await _usersProvider.getUser(id);
    return user?.displayName;
  }
}
