class FeedPost {
  String? _id;
  String? _heading;
  String? _author;
  DateTime? _dateTime;
  String? _article;
  String? _feedName;

  FeedPost.fromJson(Map<String, dynamic> data) {
    _id = data['id'];
    _heading = data['heading'];
    _author = data['author'];
    try {
      _dateTime = DateTime.parse(data['dateTime']).toLocal();
    } on FormatException catch (_) {
      _dateTime = null;
    }
    _article = data['article'];
    _feedName = data['feedName'];
  }

  String? get id => _id;
  String? get headng => _heading;
  String? get author => _author;
  DateTime? get dateTime => _dateTime;
  String? get article => _article;
  String? get feedName => _feedName;
}
