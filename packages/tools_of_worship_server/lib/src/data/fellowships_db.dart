import 'package:mongo_dart/mongo_dart.dart';
import 'package:tools_of_worship_api/tools_of_worship_server_api.dart';

class FellowshipsDatabase implements FellowshipsDataProvider {
  final DbCollection _fellowshipsCollection;
  final DbCollection _fellowshipMembersCollection;

  FellowshipsDatabase(DbCollection fellowships, DbCollection fellowshipMemebers)
      : _fellowshipsCollection = fellowships,
        _fellowshipMembersCollection = fellowshipMemebers;

  @override
  Stream<Fellowship> getUserFellowships(
      String userId, AccessLevel minAccessLevel) async* {
    var fellowshipMembersResult = _fellowshipMembersCollection.find(where
        .eq('userId', userId)
        .and(where.lte('access', minAccessLevel.toJson())));

    await for (var item in fellowshipMembersResult) {
      String id = item['fellowshipId'];

      Map<String, dynamic>? fellowshipEntry =
          await _fellowshipsCollection.findOne(where.eq('id', id));
      if (fellowshipEntry != null) {
        yield Fellowship.fromJson(fellowshipEntry);
      }
    }
  }

  @override
  Future<Fellowship?> getFellowship(String fellowshipId) async {
    Map<String, dynamic>? fellowshipEntry =
        await _fellowshipsCollection.findOne(where.eq('id', fellowshipId));
    if (fellowshipEntry == null) {
      return null;
    }

    return Fellowship.fromJson(fellowshipEntry);
  }

  @override
  Future<bool> exists(String name, String creatorId) async {
    var fellowship = await _fellowshipsCollection
        .findOne(where.eq('name', name).and(where.eq('creatorId', creatorId)));

    if (fellowship != null && fellowship.isNotEmpty) {
      return true;
    }

    return false;
  }

  @override
  Future<bool> create(String fellowshipId, String name, String userId) async {
    WriteResult result = await _fellowshipsCollection.insertOne({
      'id': fellowshipId,
      'name': name,
      'creatorId': userId,
    });

    if (!result.success) {
      return false;
    }

    if (!await addPermission(fellowshipId, userId, AccessLevel.owner)) {
      await _fellowshipsCollection.remove(where.eq('id', fellowshipId));
      return false;
    }

    return true;
  }

  @override
  Future<bool> addPermission(
      String fellowshipId, String userId, AccessLevel accessLevel) async {
    WriteResult result = await _fellowshipMembersCollection.insertOne({
      'fellowshipId': fellowshipId,
      'userId': userId,
      'access': accessLevel,
    });

    if (!result.success) {
      return false;
    }

    return true;
  }
}
