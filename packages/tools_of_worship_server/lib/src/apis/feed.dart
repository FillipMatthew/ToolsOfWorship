import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:xid/xid.dart';

class ApiFeed {
  final DbCollection _usersCollection;
  final DbCollection _postsCollection;
  final DbCollection _fellowshipsCollection;
  final DbCollection _fellowshipMembersCollection;
  final DbCollection _circlesCollection;
  final DbCollection _circleMembersCollection;

  ApiFeed(Db db)
      : _usersCollection = db.collection('Users'),
        _postsCollection = db.collection('Posts'),
        _fellowshipsCollection = db.collection('Fellowships'),
        _fellowshipMembersCollection = db.collection('FellowshipMembers'),
        _circlesCollection = db.collection('Circles'),
        _circleMembersCollection = db.collection('CircleMembers');

  Router get router {
    Router router = Router();

    router.get("/List", _getList);

    router.post("/Post", _postPost);
    router.delete("/Post", _deletePost);

    return router;
  }

  Future<Response> _getList(Request request) async {
    print('ApiFeed: _getList');

    String? userId = request.context['authDetails'] as String;

    Map<String, String> fellowshipNames = <String, String>{};

    List<String> fellowshipIds = <String>[];
    var fellowshipMembersResult = await _fellowshipMembersCollection
        .find(where.eq('userId', userId))
        .toList();

    for (var item in fellowshipMembersResult) {
      String id = item['fellowshipId'];
      fellowshipIds.add(id);

      var fellowshipEntry =
          await _fellowshipsCollection.findOne(where.eq('id', id));
      fellowshipNames[id] = fellowshipEntry?['name'];
    }

    Map<String, String> circleNames = <String, String>{};

    List<String> circleIds = <String>[];
    var circleMembersResult = await _circleMembersCollection
        .find(where.eq('userId', userId))
        .toList();

    for (var item in circleMembersResult) {
      String id = item['circleId'];
      circleIds.add(id);

      var circlesEntry = await _circlesCollection.findOne(where.eq('id', id));
      circleNames[id] = circlesEntry?['name'];
    }

    List<Map<String, dynamic>> posts = <Map<String, dynamic>>[];
    var postsResults = await _postsCollection
        .find(where.raw(
          {
            "fellowshipId": {r'$in': fellowshipIds},
            "circleId": {r'$in': circleIds},
          },
        ))
        .toList();

    for (var item in postsResults) {
      Map<String, dynamic> post = <String, dynamic>{};
      post['id'] = item['id'];
      post['heading'] = item['heading'];
      post['auther'] = await _getUserName(item['autherId']);
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
          'id': Xid().toString(),
          'autherId': userId,
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
          'id': Xid().toString(),
          'autherId': userId,
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

    String? userId = request.context['authDetails'] as String;

    return Response.internalServerError();
  }

  Future<String?> _getUserName(String id) async {
    var user = await _usersCollection.findOne(where.eq('id', id));
    String? userName = user?['displayName'];
    return userName;
  }
}
