class FeedEntry {
  final String _heading;
  final String _author;
  final String _article;
  final String _feedName;

  FeedEntry(String heading, String author, String article, String feedName)
      : _heading = heading,
        _author = author,
        _article = article,
        _feedName = feedName;

  String get headng => _heading;
  String get author => _author;
  String get article => _article;
  String get feedName => _feedName;
}

class Prayer {
  final String _heading;
  final String _author;
  final String _feedName;
  final String _summary;
  final String _fullRequest;
  final List<String> _prayerPoints;

  Prayer(String heading, String author, String feedName, String summary,
      String fullRequest, List<String> prayerPoints)
      : _heading = heading,
        _author = author,
        _feedName = feedName,
        _summary = summary,
        _fullRequest = fullRequest,
        _prayerPoints = prayerPoints;

  String get heading => _heading;
  String get author => _author;
  String get feedName => _feedName;
  String get summary => _summary;
  String get fullRequest => _fullRequest;
  List<String> get prayerPoints => _prayerPoints;
}
