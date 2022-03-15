import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/config/styling.dart';
import 'package:tools_of_worship_client/apis/types/feed_post.dart';

class FeedEntryWidget extends StatelessWidget {
  final FeedPost _entry;

  const FeedEntryWidget(FeedPost entry, {Key? key})
      : _entry = entry,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        //dense: true,
        contentPadding: const EdgeInsets.all(defaultPadding),
        title: Text(_entry.headng ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _entry.dateTime != null
                    ? '${_entry.dateTime!.year}-'
                        '${_entry.dateTime!.month.toString().padLeft(2, '0')}-'
                        '${_entry.dateTime!.day.toString().padLeft(2, '0')} '
                        '${_entry.dateTime!.hour.toString().padLeft(2, '0')}:'
                        '${_entry.dateTime!.minute.toString().padLeft(2, '0')}:'
                        '${_entry.dateTime!.second.toString().padLeft(2, '0')}'
                    : '',
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Text(_entry.article ?? ''),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _entry.author != null ? _entry.author! : '',
                  style: Theme.of(context).textTheme.caption,
                ),
                Text(
                  _entry.feedName ?? '',
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
