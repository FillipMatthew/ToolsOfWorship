import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:tools_of_worship_client/helpers/account_authentication.dart';
import 'package:tools_of_worship_client/tools_of_worship_client.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _initialising = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    try {
      if (await AccountAuthentication.signInSilent()) {
        Navigator.pushNamedAndRemoveUntil(
            context, Routing.home, (Route<dynamic> route) => false);
        return;
      }
    } on Exception catch (e) {
      showError(context, e.toString());
    }

    setState(() {
      _initialising = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // Body section
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 600) {
            return Center(
              child: SizedBox(
                width: 600.0,
                child: _body(),
              ),
            );
          } else {
            return _body();
          }
        },
      ),
    );
  }

  Widget _body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // AppBar(
          //   title: const Text('Tools of Worship'),
          // ),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Text(
              'Tools of Worship',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          _content(),
        ],
      ),
    );
  }

  Widget _content() {
    bool bDark = Theme.of(context).colorScheme.brightness == Brightness.dark;

    if (_initialising) {
      return const Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: CircularProgressIndicator(),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Text(
              'Sign In',
              style: TextStyle(fontSize: 28.0),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Text('or'),
          ),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: SignInButton(
              bDark ? Buttons.GoogleDark : Buttons.Google,
              onPressed: _signInWithGoogle,
            ),
          ),
        ],
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      if (await AccountAuthentication.authenticateWithGoogleSignIn()) {
        Navigator.pushNamedAndRemoveUntil(
            context, Routing.home, (Route<dynamic> route) => false);
        return;
      } else {
        showError(context, 'An error occured while signing in.');
      }
    } on Exception catch (e) {
      showError(context, e.toString());
    }
  }
}
