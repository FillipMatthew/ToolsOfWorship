import 'package:flutter/material.dart';

import '../api/fellowships.dart';
import '../types/fellowship.dart';

class FellowshipsProvider extends ChangeNotifier {
  ApiFellowships _apiFellowships;
  List<Fellowship> _fellowships = [];

  FellowshipsProvider(String authToken)
      : _apiFellowships = ApiFellowships(authToken);

  Future<List<Fellowship>> getFellowships() async {
    if (_fellowships.isEmpty) {
      _fellowships = await _apiFellowships.getList().toList();
      notifyListeners();
    }

    return _fellowships;
  }

  set authToken(String authToken) {
    _apiFellowships = ApiFellowships(authToken);
  }

  Future<String> getFellowshipName(String fellowshipId) async {
    if (_fellowships.isEmpty) {
      _fellowships = await _apiFellowships.getList().toList();
      notifyListeners();
    }

    for (Fellowship fellowship in _fellowships) {
      if (fellowship.id == fellowshipId) {
        return fellowship.name;
      }
    }

    return "";
  }
}
