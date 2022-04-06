import 'package:flutter/material.dart';
import 'package:tools_of_worship_client/tools_of_worship_client.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
              child: _content(),
            ),
          );
        } else {
          return _content();
        }
      }),
    );
  }

  Widget _content() {
    //bool bDark = Theme.of(context).colorScheme.brightness == Brightness.dark;

    return Column(
      children: [
        AppBar(
          title: const Text('Tools of Worship'),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Text(
                  'Signup',
                  style: TextStyle(fontSize: 28.0),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(defaultPadding),
              //   child: SignInButton(
              //     bDark ? Buttons.GoogleDark : Buttons.Google,
              //     onPressed: _signInWithGoogle,
              //   ),
              // ),
            ],
          ),
        )
      ],
    );
  }
}
