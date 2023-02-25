import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:xid/xid.dart';

import '../types/post.dart';
import 'interfaces/feed_data_provider.dart';

class ApiFeed {
  final FeedDataProvider _feedProvider;

  ApiFeed(FeedDataProvider feedProvider) : _feedProvider = feedProvider;

  Router get router {
    Router router = Router();

    router.post('/List', _postList);

    router.post('/Post', _postPost);
    router.delete('/Post', _deletePost);

    return router;
  }

  Future<Response> _postList(Request request) async {
    print('ApiFeed: _postList');

    String userId = request.context['authDetails'] as String;

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

    Stream<Post> postsResults =
        _feedProvider.getPosts(userId, limit, before, after);

    List<Post> posts = <Post>[];
    await for (Post item in postsResults) {
      posts.add(item);
    }

    return Response.ok(
      json.encode(posts),
      headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType},
    );
  }

  Future<Response> _postPost(Request request) async {
    print('ApiFeed: _postPost');

    String userId = request.context['authDetails'] as String;

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
            DateTime.now().toUtc().toIso8601String(), heading, article);
      } else if (fellowshipId != null && fellowshipId.isNotEmpty) {
        post = Post.create(Xid.string(), userId, fellowshipId, null,
            DateTime.now().toUtc().toIso8601String(), heading, article);
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

    String userId = request.context['authDetails'] as String;

    return Response.internalServerError();
  }
}
