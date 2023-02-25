import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tools_of_worship_client/config/styling.dart';

import 'package:tools_of_worship_client/providers/account_authentication.dart';

class UserSidebar extends StatelessWidget {
  const UserSidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text(context.read<AccountAuthentication>().displayName),
        ),
        const Divider(),
        ElevatedButton(
          onPressed: () {
            context.read<AccountAuthentication>().signOut();
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
