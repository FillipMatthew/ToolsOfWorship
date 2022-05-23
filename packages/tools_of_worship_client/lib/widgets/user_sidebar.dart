import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/config/styling.dart';

import 'package:tools_of_worship_client/helpers/account_authentication.dart';
import 'package:tools_of_worship_client/pages/routing.dart';

class UserSidebar extends StatelessWidget {
  const UserSidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text(AccountAuthentication().displayName),
        ),
        const Divider(),
        ElevatedButton(
          onPressed: () async {
            await AccountAuthentication().signOut();
            Navigator.pushNamedAndRemoveUntil(
                context, Routing.root, (Route<dynamic> route) => false);
          },
          child: Row(
            children: const [
              Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.logout),
              ),
              Text('Sign out'),
            ],
          ),
        )
      ],
    );
  }
}
