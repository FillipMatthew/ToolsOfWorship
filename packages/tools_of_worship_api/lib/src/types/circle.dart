class Circle {
  String? _id;
  String? _fellowshipId;
  String? _name;
  int? _type;

  Circle();

  Circle.create(String id, String fellowshipId, String name, int type)
      : _id = id,
        _fellowshipId = fellowshipId,
        _name = name,
        _type = type;

  Circle.fromJson(Map<String, dynamic> data) {
    _id = data['id'];
    _fellowshipId = data['fellowshipId'];
    _name = data['name'];
    _type = data['type'];
  }

  String get id => _id!;

  String get fellowshipId => _fellowshipId!;

  String get name => _name!;

  int get type => _type!;

  bool get isValid =>
      _id != null && _fellowshipId != null && _name != null && _type != null;
}
