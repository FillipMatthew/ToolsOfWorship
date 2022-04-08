class FeedPost {
  final String _id;
  final String _heading;
  final String _author;
  final String _dateTime;
  final String _article;
  final String _feedName;

  FeedPost(this._id, this._heading, this._author, this._dateTime, this._article,
      this._feedName);

  FeedPost.fromJson(Map<String, dynamic> data)
      : _id = data['id'],
        _heading = data['heading'],
        _author = data['author'],
        _dateTime = data['dateTime'],
        _article = data['article'],
        _feedName = data['feedName'] {
    // So we throw an exception if the date/time is invalid.
    DateTime.parse(_dateTime);
  }

  String get id => _id;
  String get headng => _heading;
  String get author => _author;
  String get dateTimeString => _dateTime;
  DateTime get dateTime => DateTime.parse(_dateTime);
  String get article => _article;
  String get feedName => _feedName;
}
