import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/feed.dart';
import '../config/styling.dart';
import '../types/post.dart';
import 'feed_entry.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  static const int _defaultFeedFetchLimit = 15;
  final List<Post> _posts = [];
  final ScrollController _controller = ScrollController();
  bool _moreToLoad = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (_controller.position.maxScrollExtent == _controller.offset) {
        _fetchMore();
      }
    });

    _onRefresh();
  }

  @override
  void dispose() {
    _controller.dispose();

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
          child: _moreToLoad
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(defaultPadding),
                    controller: _controller,
                    shrinkWrap: true,
                    itemCount: _posts.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < _posts.length) {
                        return FeedEntry(_posts[index]);
                      } else {
                        return _moreToLoad
                            ? const Center(child: CircularProgressIndicator())
                            : const Padding(
                                padding: EdgeInsets.only(
                                    left: defaultPadding,
                                    right: defaultPadding,
                                    top: 30.0,
                                    bottom: 30.0),
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
    if (_isLoading) {
      return;
    }

    _isLoading = true;

    try {
      Stream<Post> result =
          context.read<ApiFeed>().getList(limit: _defaultFeedFetchLimit);

      int count = 0;
      await for (Post post in result) {
        setState(() {
          _posts.add(post);
          ++count;
          _moreToLoad = count == _defaultFeedFetchLimit;
        });
      }

      if (count == 0) {
        setState(() {
          _moreToLoad = false;
        });
      }

      _isLoading = false;
    } catch (err) {
      _isLoading = false;
    }
  }

  Future _fetchMore() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;

    try {
      Stream<Post> result;
      if (_posts.isNotEmpty) {
        result = context.read<ApiFeed>().getList(
            limit: _defaultFeedFetchLimit, before: _posts.last.postedString);
      } else {
        result = context.read<ApiFeed>().getList(limit: _defaultFeedFetchLimit);
      }

      int count = 0;
      await for (Post post in result) {
        setState(() {
          _posts.add(post);
          ++count;
          _moreToLoad = count == _defaultFeedFetchLimit;
        });
      }

      if (count == 0) {
        setState(() {
          _moreToLoad = false;
        });
      }

      _isLoading = false;
    } catch (_) {
      _isLoading = false;
    }
  }
}
