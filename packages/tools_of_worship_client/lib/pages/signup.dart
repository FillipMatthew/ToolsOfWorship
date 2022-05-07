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
          if (constraints.maxWidth > 600.0) {
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 200.0,
          maxHeight: 400.0,
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

  Widget _content() {
    //bool bDark = Theme.of(context).colorScheme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Full name',
            ),
          ),
        ),
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
            child: const Text('Signup'),
            onPressed: _onSignup,
          ),
        ),
      ],
    );
  }

  Future<void> _onSignup() async {}
}
