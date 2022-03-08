class User {
  String _id = '';
  String _displayName = '';
  bool _isValid = false;

  User.fromMap(Map<String, dynamic> userData) {
    _id = userData['id'] ?? '';
    _displayName = userData['displayName'] ?? '';
    if (_id != '' && _displayName != '') {
      _isValid = true;
    } else {
      _isValid = false;
    }
  }

  // User.fromJson(String jsonData) {
  //   // try {
  //   //   dynamic userData = json.decode(jsonData);
  //   // } on FormatException catch (_) {
  //   //   ;
  //   // }
  // }

  bool get isValid => _isValid;

  String get id => _id;

  String get displayName => _displayName;
}
