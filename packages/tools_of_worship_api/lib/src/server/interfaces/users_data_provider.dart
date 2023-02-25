import '../../types/sign_in_type.dart';
import '../../types/user.dart';
import '../../types/user_connection.dart';

abstract class UsersDataProvider {
  // User methods
  Future<User?> getUser(String id);
  Future<User?> insertNewUser(User user);
  void removeUser(String userId);

  // UserConnection methods
  Future<UserConnection?> getUserConnection(
      SignInType signInType, String accountId);
  Future<UserConnection?> insertUserConnection(UserConnection userConnection);
}
