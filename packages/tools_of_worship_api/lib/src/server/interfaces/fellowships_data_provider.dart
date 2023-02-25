import '../../types/access_level.dart';
import '../../types/fellowship.dart';

abstract class FellowshipsDataProvider {
  Stream<Fellowship> getUserFellowships(
      String userId, AccessLevel minAccessLevel);
  Future<Fellowship?> getFellowship(String fellowshipId);
  Future<bool> exists(String name, String creatorId);
  Future<bool> create(String fellowshipId, String name, String userId);
  Future<bool> addPermission(
      String fellowshipId, String userId, AccessLevel accessLevel);
}
