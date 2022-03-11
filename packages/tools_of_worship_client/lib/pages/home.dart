import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/helpers/account_authentication.dart';
import 'package:tools_of_worship_client/pages/routing.dart';

import 'package:tools_of_worship_client/widgets/feed.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _getTitle(),
      ),
      body: _getContent(),
    );
  }

  Widget _getTitle() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 1200) {
          return Center(
            child: SizedBox(
              width: 1200.0,
              child: Row(
                children: [
                  const Text('Tools of Worship'),
                  const Spacer(flex: 2),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await AccountAuthentication.signOut();
                      Navigator.pushNamedAndRemoveUntil(context, Routing.root,
                          (Route<dynamic> route) => false);
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Text('Tools of Worship');
        }
      },
    );
  }

  Widget _getContent() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        //if (constraints.maxWidth > 1200) {
        //else if (constraints.maxWidth > 900) {
        if (constraints.maxWidth > 600) {
          return const Center(
            child: SizedBox(
              width: 600.0,
              child: FeedWidget(),
            ),
          );
        } else {
          return const FeedWidget();
        }
      },
    );
  }
}
