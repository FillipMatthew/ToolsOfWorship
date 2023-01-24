import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/config/styling.dart';
import 'package:tools_of_worship_client/apis/types/post.dart';
import 'package:tools_of_worship_client/helpers/strings.dart';

class FeedEntry extends StatelessWidget {
  final Post _entry;

  const FeedEntry(Post entry, {Key? key})
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
                formatDateTimeString(_entry.dateTime),
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Text(
                  _entry.article,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _entry.author,
                  style: Theme.of(context).textTheme.caption,
                ),
                Text(
                  _entry.feedName,
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
