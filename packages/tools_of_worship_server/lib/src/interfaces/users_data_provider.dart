import 'package:tools_of_worship_server/src/types/user.dart';
import 'package:tools_of_worship_server/src/types/user_connection.dart';

abstract class UsersDataProvider {
  // User methods
  Future<User?> getUser(String id);
  Future<User?> insertNewUser(User user);
  void removeUser(String userId);

  // UserConnection methods
  Future<UserConnection?> getUserConnection(int signInType, String accountId);
  Future<UserConnection?> insertUserConnection(UserConnection userConnection);
}