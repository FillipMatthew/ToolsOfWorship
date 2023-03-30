import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/styling.dart';
import '../providers/account_authentication.dart';

class UserSidebar extends StatelessWidget {
  final Function()? _onCompleted;

  const UserSidebar({Function()? onCompleted, Key? key})
      : _onCompleted = onCompleted,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text(context.select<AccountAuthentication, String>(
              (accountAuth) => accountAuth.displayName)),
        ),
        const Divider(),
        ElevatedButton(
          onPressed: () {
            _onCompleted!();
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
