class Post {
  String? _id;
  String? _authorId;
  String? _fellowshipId;
  String? _circleId;
  String?
      _dateTime; // Keep the datetime as a string since precision varies across devices.
  String? _heading;
  String? _article;

  Post();

  Post.create(String id, String authorId, String? fellowshipId,
      String? circleId, String dateTime, String heading, String article)
      : _id = id,
        _authorId = authorId,
        _fellowshipId = fellowshipId,
        _circleId = circleId,
        _dateTime = dateTime,
        _heading = heading,
        _article = article;

  Map<String, dynamic> toJson() {
    if (isValid) {
      return {
        'id': _id,
        'authorId': _authorId,
        'fellowshipId': _fellowshipId,
        'circleId': _circleId,
        'dateTime': _dateTime,
        'heading': _heading,
        'article': _article,
      };
    } else {
      return {};
    }
  }

  Post.fromJson(Map<String, dynamic> data)
      : _id = data['id'],
        _authorId = data['authorId'],
        _fellowshipId = data['fellowshipId'],
        _circleId = data['circleId'],
        _dateTime = data['dateTime'],
        _heading = data['heading'],
        _article = data['article'] {
    // So we throw an exception if the date/time is invalid.
    DateTime.parse(_dateTime!);
  }

  String get id => _id!;

  String get authorId => _authorId!;

  String? get fellowshipId => _fellowshipId;

  String? get circleId => _circleId;

  String get dateTimeString => _dateTime!;

  DateTime get dateTime => DateTime.parse(_dateTime!);

  String get heading => _heading!;

  String get article => _article!;

  bool get isValid =>
      _id != null &&
      _authorId != null &&
      ((fellowshipId != null && fellowshipId!.isNotEmpty) ||
          (_circleId != null && circleId!.isNotEmpty)) &&
      _dateTime != null &&
      _heading != null &&
      _article != null;
}
