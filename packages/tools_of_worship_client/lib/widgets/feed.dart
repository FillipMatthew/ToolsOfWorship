import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/apis/feed.dart';
import 'package:tools_of_worship_client/config/styling.dart';
import 'package:tools_of_worship_client/apis/types/feed_post.dart';
import 'package:tools_of_worship_client/widgets/feed_entry.dart';

class FeedWidget extends StatefulWidget {
  const FeedWidget({Key? key}) : super(key: key);

  @override
  _FeedWidgetState createState() => _FeedWidgetState();
}

class _FeedWidgetState extends State<FeedWidget> {
  List<FeedPost> posts = <FeedPost>[];

  @override
  void initState() {
    super.initState();

    _onRefresh();
  }

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
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: posts.length,
              itemBuilder: (BuildContext context, int index) {
                return FeedEntryWidget(posts[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onRefresh() async {
    var result = await ApiFeed.getList();
    setState(() {
      posts = result;
    });
  }
}
