import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/config/styling.dart';
import 'package:tools_of_worship_client/apis/data_types.dart';

class FeedEntryWidget extends StatelessWidget {
  final FeedEntry _entry;

  const FeedEntryWidget(FeedEntry entry, {Key? key})
      : _entry = entry,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        //dense: true,
        contentPadding: const EdgeInsets.all(defaultPadding),
        title: Text(_entry.headng),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _entry.author,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Text(_entry.article),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _entry.feedName,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
