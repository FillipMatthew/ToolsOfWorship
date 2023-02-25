import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tools_of_worship_api/tools_of_worship_client_api.dart';

import '../config/styling.dart';
import '../widgets/feed.dart';
import '../widgets/new_post.dart';
import '../widgets/page_wrapper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                    onPressed: () => _showNewPost(context),
                    child: const Icon(Icons.post_add),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Future<void> _showNewPost(BuildContext context) {
    ApiFellowships apiFellowships =
        Provider.of<ApiFellowships>(context, listen: false);
    ApiFeed apiFeed = Provider.of<ApiFeed>(context, listen: false);

    return showDialog<void>(
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  defaultPadding, 60, defaultPadding, defaultPadding),
              child: Card(
                color: Theme.of(context)
                    .cardColor
                    .withOpacity(defaultOverlayOpacity),
                elevation: defaultMenuElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: MultiProvider(
                    providers: [
                      Provider<ApiFellowships>.value(value: apiFellowships),
                      Provider<ApiFeed>.value(value: apiFeed),
                    ],
                    child: NewPost(onCompleted: (cancelled) {
                      Navigator.of(context).pop();
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
