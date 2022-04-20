import 'package:flutter/material.dart';

import 'package:tools_of_worship_client/widgets/feed.dart';
import 'package:tools_of_worship_client/widgets/page_wrapper.dart';
import 'package:tools_of_worship_client/config/styling.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: const FeedWidget(),
        ),
      ),
    );
  }
}
