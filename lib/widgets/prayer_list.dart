import 'package:flutter/material.dart';

import '../config/styling.dart';
import 'prayer_list_entry.dart';

class PrayerList extends StatelessWidget {
  static const List<String> prayerList = [
    'Description of prayer item 1.',
    'Description of prayer item 2.'
  ];

  const PrayerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Prayer List'),
        ),
      ),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: ListView.builder(
          padding: const EdgeInsets.all(defaultPadding),
          itemCount: prayerList.length,
          itemBuilder: (BuildContext context, int index) {
            return PrayerListEntry(prayerList[index]);
          },
        ),
      ),
    );
  }
}
