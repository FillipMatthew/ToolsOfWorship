import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/config/styling.dart';
import 'package:tools_of_worship_client/apis/data_types.dart';
import 'package:tools_of_worship_client/widgets/feed_entry.dart';

class FeedWidget extends StatelessWidget {
  const FeedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            'Feed',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 50,
            itemBuilder: (BuildContext context, int index) {
              return FeedEntryWidget(
                FeedEntry('Heading', 'Author',
                    'This is some random article text.', 'Test news feed'),
                key: ValueKey(index),
              );
            },
          ),
        ),
      ],
    );
  }
}
