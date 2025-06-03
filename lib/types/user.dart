class User {
  String? _id;
  String? _displayName;

  User();

  User.create(String id, String displayName)
      : _id = id,
        _displayName = displayName;

  User.fromJson(Map<String, dynamic> userData) {
    _id = userData['id'];
    _displayName = userData['displayName'];
  }

  String get id => _id!;

  String get displayName => _displayName!;

  bool get isValid => _id != null && _displayName != null;
}
