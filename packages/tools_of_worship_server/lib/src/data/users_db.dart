import 'package:mongo_dart/mongo_dart.dart';
import 'package:tools_of_worship_api/tools_of_worship_server_api.dart';

class UsersDatabase implements UsersDataProvider {
  final DbCollection _userConnectionsCollection;
  final DbCollection _usersCollection;

  UsersDatabase(
      DbCollection usersCollection, DbCollection userConnectionCollection)
      : _usersCollection = usersCollection,
        _userConnectionsCollection = userConnectionCollection;

  @override
  Future<User?> getUser(String id) async {
    Map<String, dynamic>? userData =
        await _usersCollection.findOne(where.eq('id', id));

    if (userData == null) {
      return null;
    }

    return User.fromJson(userData);
  }

  @override
  Future<User?> insertNewUser(User user) async {
    if (!user.isValid) {
      return null;
    }

    WriteResult result = await _usersCollection.insertOne({
      'id': user.id,
      'displayName': user.displayName,
    });

    if (!result.isSuccess || result.document == null) {
      print('Failed to insert user into database.');
      return null;
    }

    return User.fromJson(result.document!);
  }

  @override
  void removeUser(String userId) {
    _usersCollection.remove(where.eq('id', userId));
    _userConnectionsCollection.remove(where.eq('id', userId));
  }

  @override
  Future<UserConnection?> getUserConnection(
      SignInType signInType, String accountId) async {
    Map<String, dynamic>? accountData =
        await _userConnectionsCollection.findOne(where
            .eq('signInType', signInType.toJson())
            .and(where.eq('accountId', accountId)));

    if (accountData == null) {
      print('Could not find the user connection.');
      return null;
    }

    return UserConnection.fromJson(accountData);
  }

  @override
  Future<UserConnection?> insertUserConnection(
      UserConnection userConnection) async {
    if (!userConnection.isValid) {
      return null;
    }

    WriteResult result = await _userConnectionsCollection.insertOne({
      'userId': userConnection.userId,
      'signInType': userConnection.signInType,
      'accountId': userConnection.accountId,
      'authDetails': userConnection.authDetails,
    });

    if (!result.isSuccess || result.document == null) {
      print('Failed to insert user connection into database.');
      return null;
    }

    return UserConnection.fromJson(result.document!);
  }
}
