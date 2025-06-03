class Fellowship {
  String? _id;
  String? _name;
  String? _creatorId;

  Fellowship();

  Fellowship.create(String id, String name, String creator)
      : _id = id,
        _name = name,
        _creatorId = creator;

  Fellowship.fromJson(Map<String, dynamic> data) {
    _id = data['id'];
    _name = data['name'];
    _creatorId = data['creatorId'];
  }

  String get id => _id!;

  String get name => _name!;

  String? get creatorId => _creatorId;

  bool get isValid => _id != null && _name != null && _creatorId != null;

  Map<String, dynamic> toJson() => isValid
      ? {
          'id': _id,
          'name': _name,
          'creatorId': _creatorId,
        }
      : {};
}
