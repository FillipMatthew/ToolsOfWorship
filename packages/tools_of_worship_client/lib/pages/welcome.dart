import 'package:flutter/material.dart';
import 'package:sign_button/create_button.dart';
import 'package:sign_button/sign_button.dart';
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
    if (_initialising) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Text(
                'Tools of Worship',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 200,
            maxHeight: 400,
          ),
          child: Card(
            elevation: 4.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
          ),
        ),
      );
    }
  }

  Widget _content() {
    bool bDark = Theme.of(context).colorScheme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Email',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Password',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: ElevatedButton(
            child: const Text('Sign In'),
            onPressed: _onSignIn,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Text('or'),
        ),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: SignInButton(
            buttonType: bDark ? ButtonType.googleDark : ButtonType.google,
            onPressed: _signInWithGoogle,
          ),
        ),
      ],
    );
  }

  Future<void> _onSignIn() async {}

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
