import '../../types/access_level.dart';
import '../../types/circle.dart';

abstract class CirclesDataProvider {
  Stream<Circle> getUserCircles(String userId, AccessLevel minAccessLevel);
  Future<Circle?> getCircle(String circleId);
  Future<bool> exists(String name, String creatorId);
  Future<bool> create(String circleId, String fellowshipId, String name,
      int type, String userId);
  Future<bool> addPermission(
      String circleId, String userId, AccessLevel accessLevel);
}
