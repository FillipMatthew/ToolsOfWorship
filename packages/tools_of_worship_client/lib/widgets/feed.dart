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
  static const int _defaultFeedFetchLimit = 15;
  List<FeedPost> posts = [];
  final ScrollController controller = ScrollController();
  bool moreToLoad = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        _fetchMore();
      }
    });

    _onRefresh();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
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
          child: posts.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(defaultPadding),
                    controller: controller,
                    shrinkWrap: true,
                    itemCount: posts.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < posts.length) {
                        return FeedEntryWidget(posts[index]);
                      } else {
                        return moreToLoad
                            ? const Center(child: CircularProgressIndicator())
                            : const Padding(
                              padding:  EdgeInsets.only(left: defaultPadding, right: defaultPadding, top: 30.0, bottom: 30.0),
                              child: Center(child: Text('No more posts')));
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Future _onRefresh() async {
    if (isLoading) {
      return;
    }

    isLoading = true;

    try {
      List<FeedPost> result =
          await ApiFeed.getList(limit: _defaultFeedFetchLimit);

      setState(() {
        posts = result;
        moreToLoad = result.length == _defaultFeedFetchLimit;
        isLoading = false;
      });
    } catch (_) {
      isLoading = false;
    }
  }

  Future _fetchMore() async {
    if (isLoading) {
      return;
    }

    isLoading = true;

    try {
      List<FeedPost> result;
      if (posts.isNotEmpty) {
        result = await ApiFeed.getList(
            limit: _defaultFeedFetchLimit, before: posts.last.dateTimeString);
      } else {
        result = await ApiFeed.getList(limit: _defaultFeedFetchLimit);
      }

      setState(() {
        if (result.isNotEmpty) {
          posts.addAll(result);
        } else {
          moreToLoad = false;
        }

        moreToLoad = result.length == _defaultFeedFetchLimit;

        isLoading = false;
      });
    } catch (_) {
      isLoading = false;
    }
  }
}
