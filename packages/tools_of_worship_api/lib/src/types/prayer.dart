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
