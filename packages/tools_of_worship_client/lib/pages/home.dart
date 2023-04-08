import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tools_of_worship_api/tools_of_worship_client_api.dart';

import '../config/styling.dart';
import '../dialogs/dialog_wrapper.dart';
import '../widgets/feed.dart';
import '../widgets/new_post.dart';
import '../widgets/page_wrapper.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    bool useSideMenu =
        width > maxContentWidth; /* > (maxContentWidth + sideMenuMinWidth)*/

    return PageWrapper(
      child: Scaffold(
        body: const Feed(),
        floatingActionButton: !useSideMenu
            ? FloatingActionButton(
                onPressed: () => _showNewPost(context),
                child: const Icon(Icons.post_add),
              )
            : null,
      ),
    );
  }

  Future<void> _showNewPost(BuildContext context) {
    ApiFellowships apiFellowships =
        Provider.of<ApiFellowships>(context, listen: false);
    ApiFeed apiFeed = Provider.of<ApiFeed>(context, listen: false);

    return showDialog<void>(
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return DialogWrapper(
          child: MultiProvider(
            providers: [
              Provider<ApiFellowships>.value(value: apiFellowships),
              Provider<ApiFeed>.value(value: apiFeed),
            ],
            child: NewPost(
              onCompleted: (cancelled) {
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }
}
