import 'package:flutter/material.dart';
import 'package:tools_of_worship_api/tools_of_worship_client_api.dart';

class FellowshipsProvider extends ChangeNotifier {
  ApiFellowships _apiFellowships;
  List<Fellowship> _fellowships = [];

  FellowshipsProvider(String authToken)
      : _apiFellowships = ApiFellowships(authToken);

  Future<List<Fellowship>> getFellowships() async {
    if (_fellowships.isEmpty) {
      _fellowships = await _apiFellowships.getList().toList();
    }

    return _fellowships;
  }

  set authToken(String authToken) {
    _apiFellowships = ApiFellowships(authToken);
  }
}
