import 'package:mongo_dart/mongo_dart.dart';
import 'package:tools_of_worship_server/src/interfaces/fellowships_data_provider.dart';
import 'package:tools_of_worship_server/src/types/access_level.dart';

class FellowshipsDatabase implements FellowshipsDataProvider {
  final DbCollection _fellowshipsCollection;
  final DbCollection _fellowshipMembersCollection;

  FellowshipsDatabase(DbCollection fellowships, DbCollection fellowshipMemebers)
      : _fellowshipsCollection = fellowships,
        _fellowshipMembersCollection = fellowshipMemebers;

  @override
  Future<void> getUserFellowships(String userId, int minAccessLevel,
      Map<String, String> userFellowships) async {
    var fellowshipMembersResult = _fellowshipMembersCollection.find(
        where.eq('userId', userId).and(where.lte('access', minAccessLevel)));

    await for (var item in fellowshipMembersResult) {
      String id = item['fellowshipId'];

      var fellowshipEntry =
          await _fellowshipsCollection.findOne(where.eq('id', id));
      userFellowships[id] = fellowshipEntry?['name'];
    }
  }

  @override
  Future<bool> exists(String name, String creatorId) async {
    var fellowship = await _fellowshipsCollection
        .findOne(where.eq('name', name).and(where.eq('creator', creatorId)));

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
      'creator': userId,
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
      String fellowshipId, String userId, int accessLevel) async {
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
