import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:tools_of_worship_server/src/interfaces/fellowships_data_provider.dart';
import 'package:tools_of_worship_server/src/types/access_level.dart';
import 'package:xid/xid.dart';

class ApiFeed {
  final DbCollection _usersCollection;
  final DbCollection _postsCollection;
  final FellowshipsDataProvider _fellowshipsDataProvider;
  final DbCollection _circlesCollection;
  final DbCollection _circleMembersCollection;

  ApiFeed(
      DbCollection users,
      DbCollection posts,
      FellowshipsDataProvider fellowshipsDataProvider,
      DbCollection circles,
      DbCollection circleMembers)
      : _usersCollection = users,
        _postsCollection = posts,
        _fellowshipsDataProvider = fellowshipsDataProvider,
        _circlesCollection = circles,
        _circleMembersCollection = circleMembers;

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

    List<String> fellowshipIds = [];
    Map<String, String> fellowshipNames = <String, String>{};
    await _fellowshipsDataProvider.getUserFellowships(userId, AccessLevel.readOnly, fellowshipNames);
    for (String key in fellowshipNames.keys)
    {
      fellowshipIds.add(key);
    }

    Map<String, String> circleNames = <String, String>{};

    List<String> circleIds = <String>[];
    var circleMembersResult =
        _circleMembersCollection.find(where.eq('userId', userId));

    await for (var item in circleMembersResult) {
      String id = item['circleId'];
      circleIds.add(id);

      var circlesEntry = await _circlesCollection.findOne(where.eq('id', id));
      circleNames[id] = circlesEntry?['name'];
    }

    SelectorBuilder selectorBuilder = where;
    if (fellowshipIds.isNotEmpty) {
      selectorBuilder = selectorBuilder.oneFrom('fellowshipId', fellowshipIds);
    }

    if (circleIds.isNotEmpty) {
      selectorBuilder = selectorBuilder.oneFrom('circleId', circleIds);
    }

    if (before != null) {
      selectorBuilder =
          selectorBuilder.lt('dateTime', before.toUtc().toIso8601String());
    }

    if (after != null) {
      selectorBuilder =
          selectorBuilder.gt('dateTime', after.toUtc().toIso8601String());
    }

    bool descending = (before == null && after != null) ? false : true;
    selectorBuilder =
        selectorBuilder.sortBy('dateTime', descending: descending);
    if (limit != null) {
      selectorBuilder = selectorBuilder.limit(limit);
    }

    List<Map<String, dynamic>> posts = <Map<String, dynamic>>[];
    if (fellowshipIds.isNotEmpty || circleIds.isNotEmpty) {
      // We should have at least one list of items to filter by.
      var postsResults = _postsCollection.find(selectorBuilder);

      await for (var item in postsResults) {
        Map<String, dynamic> post = <String, dynamic>{};
        post['id'] = item['id'];
        post['heading'] = item['heading'];
        post['author'] = await _getUserName(item['authorId']);
        post['dateTime'] = item['dateTime'];
        post['article'] = item['article'];

        String feedName = '';
        String? fellowshipId = item['fellowshipId'];
        String? circleId = item['circleId'];
        if (fellowshipId != null) {
          feedName += fellowshipNames[fellowshipId] ?? '';
        }

        if (circleId != null) {
          feedName += '(${circleNames[fellowshipId]})';
        }

        post['feedName'] = feedName;

        posts.add(post);
      }
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

      if (fellowshipId != null && fellowshipId.isNotEmpty) {
        WriteResult result = await _postsCollection.insertOne({
          'id': Xid.string(),
          'authorId': userId,
          'fellowshipId': fellowshipId,
          'dateTime': DateTime.now().toUtc().toIso8601String(),
          'heading': heading,
          'article': article,
        });

        if (result.success) {
          return Response.ok('');
        }
      } else if (circleId != null && circleId.isNotEmpty) {
        WriteResult result = await _postsCollection.insertOne({
          'id': Xid.string(),
          'authorId': userId,
          'circleId': circleId,
          'dateTime': DateTime.now().toUtc().toIso8601String(),
          'heading': heading,
          'article': article,
        });

        if (result.success) {
          return Response.ok('');
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
    var user = await _usersCollection.findOne(where.eq('id', id));
    String? userName = user?['displayName'];
    return userName;
  }
}
