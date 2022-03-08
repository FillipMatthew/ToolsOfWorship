import 'package:flutter/material.dart';

import 'package:tools_of_worship_client/config/styling.dart';

class PrayerListItem extends StatelessWidget {
  final String description;

  const PrayerListItem(this.description, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(description),
      //padding: EdgeInsets.all(8.0),
      //child: Text(description),
    );
  }
}

class PrayerListView extends StatelessWidget {
  static const List<String> prayerList = [
    'Description of prayer item 1.',
    'Description of prayer item 2.'
  ];

  const PrayerListView({Key? key}) : super(key: key);

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
            return PrayerListItem(prayerList[index]);
          },
        ),
      ),
    );
  }
}
