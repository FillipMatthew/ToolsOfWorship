class Post {
  String? _id;
  String? _authorId;
  String? _fellowshipId;
  String? _circleId;
  DateTime? _dateTime;
  String? _heading;
  String? _article;

  Post();

  Post.create(String id, String author, String? fellowshipId, String? circleId,
      DateTime dateTime, String heading, String article)
      : _id = id,
        _authorId = author,
        _fellowshipId = fellowshipId,
        _circleId = circleId,
        _dateTime = dateTime,
        _heading = heading,
        _article = article;

  Post.fromJson(Map<String, dynamic> userData) {
    _id = userData['id'];
    _authorId = userData['authorId'];
    _fellowshipId = userData['fellowshipId'];
    _circleId = userData['circleId'];
    _dateTime = DateTime.parse(userData['dateTime']);
    _heading = userData['heading'];
    _article = userData['article'];
  }

  String get id => _id!;

  String get authorId => _authorId!;

  String? get fellowshipId => _fellowshipId;

  String? get circleId => _circleId;

  DateTime get dateTime => _dateTime!;

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
