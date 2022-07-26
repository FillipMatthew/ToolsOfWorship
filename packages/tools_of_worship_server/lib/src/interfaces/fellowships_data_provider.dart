import 'package:tools_of_worship_server/src/types/access_level.dart';

abstract class FellowshipsDataProvider {
  Future<void> getUserFellowships(String userId, int minAccessLevel, Map<String, String> userFellowships);
  Future<bool> exists(String name, String creatorId);
  Future<bool> create(String fellowshipId, String name, String userId);
  Future<bool> addPermission(String fellowshipId, String userId, int accessLevel);
}
