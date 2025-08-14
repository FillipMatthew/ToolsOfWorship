import 'package:flutter/material.dart';

import '../config/styling.dart';
import '../helpers/strings.dart';
import '../types/post.dart';

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
        title: Text(_entry.heading),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                formatDateTimeString(_entry.posted),
                style: Theme.of(context).textTheme.bodySmall,
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
                  "", //_entry.authorName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  "", //_entry.feedName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
