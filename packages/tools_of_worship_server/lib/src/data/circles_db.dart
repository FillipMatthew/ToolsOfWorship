import 'package:mongo_dart/mongo_dart.dart';
import 'package:tools_of_worship_server/src/interfaces/circles_data_provider.dart';
import 'package:tools_of_worship_server/src/types/access_level.dart';
import 'package:tools_of_worship_server/src/types/circle.dart';

class CirclesDatabase implements CirclesDataProvider {
  final DbCollection _circlesCollection;
  final DbCollection _circleMembersCollection;

  CirclesDatabase(DbCollection circles, DbCollection circleMemebers)
      : _circlesCollection = circles,
        _circleMembersCollection = circleMemebers;

  @override
  Stream<Circle> getUserCircles(String userId, int minAccessLevel) async* {
    var circleMembersResult = _circleMembersCollection.find(
        where.eq('userId', userId).and(where.lte('access', minAccessLevel)));

    await for (var item in circleMembersResult) {
      String id = item['circleId'];

      Map<String, dynamic>? circleEntry =
          await _circlesCollection.findOne(where.eq('id', id));
      if (circleEntry != null) {
        yield Circle.fromJson(circleEntry);
      }
    }
  }

  @override
  Future<Circle?> getCircle(String circleId) async {
    Map<String, dynamic>? circleEntry =
        await _circlesCollection.findOne(where.eq('id', circleId));
    if (circleEntry == null) {
      return null;
    }

    return Circle.fromJson(circleEntry);
  }

  @override
  Future<bool> exists(String name, String creatorId) async {
    var circle = await _circlesCollection
        .findOne(where.eq('name', name).and(where.eq('creatorId', creatorId)));

    if (circle != null && circle.isNotEmpty) {
      return true;
    }

    return false;
  }

  @override
  Future<bool> create(String circleId, String fellowshipId, String name,
      int type, String userId) async {
    WriteResult result = await _circlesCollection.insertOne({
      'id': circleId,
      'fellowshipId': fellowshipId,
      'name': name,
      'type': type,
    });

    if (!result.success) {
      return false;
    }

    if (!await addPermission(circleId, userId, AccessLevel.admin)) {
      await _circlesCollection.remove(where.eq('id', circleId));
      return false;
    }

    return true;
  }

  @override
  Future<bool> addPermission(
      String circleId, String userId, int accessLevel) async {
    WriteResult result = await _circleMembersCollection.insertOne({
      'circleId': circleId,
      'userId': userId,
      'access': accessLevel,
    });

    if (!result.success) {
      return false;
    }

    return true;
  }
}
