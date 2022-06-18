import 'package:flutter/material.dart';

class PrayerListEntry extends StatelessWidget {
  final String description;

  const PrayerListEntry(this.description, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(description),
      //padding: EdgeInsets.all(8.0),
      //child: Text(description),
    );
  }
}