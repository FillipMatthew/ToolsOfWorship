class FeedPost {
  final String _id;
  final String _heading;
  final String _author;
  final DateTime _dateTime;
  final String _article;
  final String _feedName;

  FeedPost(this._id, this._heading, this._author, this._dateTime, this._article,
      this._feedName);

  FeedPost.fromJson(Map<String, dynamic> data)
      : _id = data['id'],
        _heading = data['heading'],
        _author = data['author'],
        _dateTime = DateTime.parse(data['dateTime']).toLocal(),
        _article = data['article'],
        _feedName = data['feedName'];

  String get id => _id;
  String get headng => _heading;
  String get author => _author;
  DateTime get dateTime => _dateTime;
  String get article => _article;
  String get feedName => _feedName;
}
