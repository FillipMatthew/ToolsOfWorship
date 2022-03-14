class User {
  String _id = '';
  String _displayName = '';

  User.fromJson(Map<String, dynamic> userData) {
    _id = userData['id'] ?? '';
    _displayName = userData['displayName'] ?? '';
  }

  String get id => _id;

  String get displayName => _displayName;
}
