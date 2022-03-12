import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/helpers/account_authentication.dart';
import 'package:tools_of_worship_client/pages/routing.dart';

import 'package:tools_of_worship_client/widgets/feed.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 1200.0) {
            return Center(
              child: SizedBox(
                width: 1200.0,
                child: _getContent(context),
              ),
            );
          } else {
            return Center(child: _getContent(context));
          }
        },
      ),
    );
  }

  Widget _getContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppBar(
          title: const Text('Tools of Worship'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await AccountAuthentication.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, Routing.root, (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth > 600.0) {
                return const SizedBox(
                  width: 600.0,
                  child: FeedWidget(),
                );
              } else {
                return const FeedWidget();
              }
            },
          ),
        ),
      ],
    );
  }
}
