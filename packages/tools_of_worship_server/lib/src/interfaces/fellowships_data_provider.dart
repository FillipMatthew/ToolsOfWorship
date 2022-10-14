import 'package:tools_of_worship_server/src/types/fellowship.dart';

abstract class FellowshipsDataProvider {
  Stream<Fellowship> getUserFellowships(String userId, int minAccessLevel);
  Future<Fellowship?> getFellowship(String fellowshipId);
  Future<bool> exists(String name, String creatorId);
  Future<bool> create(String fellowshipId, String name, String userId);
  Future<bool> addPermission(
      String fellowshipId, String userId, int accessLevel);
}
