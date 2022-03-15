import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:tools_of_worship_server/src/types/access_level.dart';
import 'package:xid/xid.dart';

class ApiFellowships {
  final DbCollection _fellowshipsCollection;
  final DbCollection _fellowshipMembersCollection;

  ApiFellowships(DbCollection fellowships, DbCollection fellowshipMemebers)
      : _fellowshipsCollection = fellowships,
        _fellowshipMembersCollection = fellowshipMemebers;

  Router get router {
    Router router = Router();

    router.post("/Add", _postAdd);
    router.post("/Join", _postJoin);

    return router;
  }

  Future<Response> _postAdd(Request request) async {
    print('ApiFellowship: _postAdd');

    String? userId = request.context['authDetails'] as String;

    final payload = await request.readAsString();

    try {
      dynamic data = json.decode(payload);
      String? name = data['name'];
      if (name == null || name.isEmpty) {
        return Response.forbidden('Invalid request.');
      }

      var fellowship = await _fellowshipsCollection
          .findOne(where.eq('name', name).and(where.eq('creator', userId)));

      if (fellowship != null && fellowship.isNotEmpty) {
        return Response.forbidden('Already exists.');
      }

      String fellowshipId = Xid.string();

      WriteResult result = await _fellowshipsCollection.insertOne({
        'id': fellowshipId,
        'name': name,
        'creator': userId,
      });

      if (!result.success) {
        return Response.internalServerError();
      }

      result = await _fellowshipMembersCollection.insertOne({
        'fellowshipId': fellowshipId,
        'userId': userId,
        'access': AccessLevel.owner,
      });

      if (!result.success) {
        await _fellowshipsCollection.remove(where.eq('id', fellowshipId));
        return Response.internalServerError();
      }

      return Response.ok(
        json.encode({
          'id': fellowshipId,
          'name': name,
        }),
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType},
      );
    } on FormatException catch (_) {
      return Response.forbidden('Invalid request.');
    }
  }

  Future<Response> _postJoin(Request request) async {
    print('ApiFellowship: _postJoin');
    return Response.internalServerError();
  }
}
