class User {
  String _id = '';
  String _displayName = '';

  User.fromJson(Map<String, dynamic> userData) {
    _id = userData['id'] ?? '';
    _displayName = userData['displayName'] ?? '';
  }

  // User.fromJson(String jsonData) {
  //   // try {
  //   //   dynamic userData = json.decode(jsonData);
  //   // } on FormatException catch (_) {
  //   //   ;
  //   // }
  // }

  String get id => _id;

  String get displayName => _displayName;
}
