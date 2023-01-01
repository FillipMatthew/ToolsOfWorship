import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/helpers/account_authentication.dart';
import 'package:tools_of_worship_client/pages/routing.dart';
import 'package:tools_of_worship_client/pages/welcome.dart';

class AuthWrapper extends StatelessWidget {
  final Widget _child;

  const AuthWrapper({required Widget child, Key? key})
      : _child = child,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authenticate(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == true) {
            return _child;
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamedAndRemoveUntil(
                  context, Routing.login, (Route<dynamic> route) => false);
            });
          }
        } else {
          if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamedAndRemoveUntil(
                  context, Routing.login, (Route<dynamic> route) => false);
            });
          }
        }

        return const WelcomePage();
      },
    );
  }

  Future<bool> _authenticate() async {
    if (AccountAuthentication().isSignedIn) {
      return true;
    } else {
      return AccountAuthentication().signInSilent();
    }
  }
}
