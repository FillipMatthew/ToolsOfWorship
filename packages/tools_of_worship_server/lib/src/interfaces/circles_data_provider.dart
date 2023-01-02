import 'package:tools_of_worship_server/src/types/circle.dart';

abstract class CirclesDataProvider {
  Stream<Circle> getUserCircles(String userId, int minAccessLevel);
  Future<Circle?> getCircle(String circleId);
  Future<bool> exists(String name, String creatorId);
  Future<bool> create(String circleId, String fellowshipId, String name,
      int type, String userId);
  Future<bool> addPermission(String circleId, String userId, int accessLevel);
}
