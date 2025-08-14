class Post {
  String? _id;
  String? _authorId;
  String? _fellowshipId;
  String? _circleId;
  String?
      _posted; // Keep the datetime as a string since precision varies across devices.
  String? _heading;
  String? _article;

  Post();

  Post.create(String id, String authorId, String? fellowshipId,
      String? circleId, String posted, String heading, String article)
      : _id = id,
        _authorId = authorId,
        _fellowshipId = fellowshipId,
        _circleId = circleId,
        _posted = posted,
        _heading = heading,
        _article = article;

  Map<String, dynamic> toJson() {
    if (isValid) {
      return {
        'id': _id,
        'authorId': _authorId,
        'fellowshipId': _fellowshipId,
        'circleId': _circleId,
        'posted': _posted,
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
        _posted = data['posted'],
        _heading = data['heading'],
        _article = data['article'] {
    // So we throw an exception if the date/time is invalid.
    DateTime.parse(_posted!);
  }

  String get id => _id!;

  String get authorId => _authorId!;

  String? get fellowshipId => _fellowshipId;

  String? get circleId => _circleId;

  String get postedString => _posted!;

  DateTime get posted => DateTime.parse(_posted!);

  String get heading => _heading!;

  String get article => _article!;

  bool get isValid =>
      _id != null &&
      _authorId != null &&
      ((fellowshipId != null && fellowshipId!.isNotEmpty) ||
          (_circleId != null && circleId!.isNotEmpty)) &&
      _posted != null &&
      _heading != null &&
      _article != null;
}
