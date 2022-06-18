import 'package:flutter/material.dart';

import 'package:tools_of_worship_client/widgets/feed.dart';
import 'package:tools_of_worship_client/widgets/new_post.dart';
import 'package:tools_of_worship_client/widgets/page_wrapper.dart';
import 'package:tools_of_worship_client/config/styling.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  OverlayEntry? _newPostOverlay;

  @override
  void dispose() {
    _hideNewPost();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    bool useToolbarMenu = screenWidth <= maxContentWidth;

    return PageWrapper(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Scaffold(
            body: const Feed(),
            floatingActionButton: useToolbarMenu
                ? FloatingActionButton(
                    child: const Icon(Icons.post_add),
                    onPressed: () {
                      _showNewPost();
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  void _showNewPost() {
    if (_newPostOverlay != null) {
      return;
    }

    _newPostOverlay = OverlayEntry(
      builder: (context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double width = screenWidth <= maxContentWidth
            ? screenWidth - (defaultPadding * 2)
            : maxContentWidth - (defaultPadding * 2);
        final double sidePadding = (screenWidth - width) / 2.0;

        return Positioned(
          left: sidePadding,
          right: sidePadding,
          bottom: defaultPadding,
          top: 60.0,
          child: Card(
            color:
                Theme.of(context).cardColor.withOpacity(defaultOverlayOpacity),
            elevation: defaultMenuElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: NewPost(
                onCompleted: _onNewPostComplete,
              ),
            ),
          ),
        );
      },
    );

    final overlay = Overlay.of(context);
    overlay?.insert(_newPostOverlay!);
  }

  void _hideNewPost() {
    _newPostOverlay?.remove();
    _newPostOverlay = null;
  }

  void _onNewPostComplete(bool cancelled) {
    _hideNewPost();
  }
}
