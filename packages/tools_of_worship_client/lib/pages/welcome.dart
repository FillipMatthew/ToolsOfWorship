import 'package:flutter/material.dart';
import 'package:sign_button/sign_button.dart';
import 'package:string_validator/string_validator.dart';
import 'package:tools_of_worship_client/helpers/account_authentication.dart';
import 'package:tools_of_worship_client/tools_of_worship_client.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _initialising = true;
  bool _visiblePassword = false;
  // String? _error;
  String? _email;
  String? _password;

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
    if (_initialising) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
            minHeight: 200.0,
          ),
          child: Card(
            elevation: 4.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Text(
                    'Tools of Worship',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                // if (_error != null && _error!.isNotEmpty)
                //   Padding(
                //     padding: const EdgeInsets.all(defaultPadding),
                //     child: Text(
                //       _error!,
                //       style: TextStyle(color: Theme.of(context).errorColor),
                //     ),
                //   ),
                Form(
                  key: _formKey,
                  child: _content(),
                ),
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
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            validator: _emailValidator,
            textInputAction: TextInputAction.next,
            onChanged: (val) {
              _email = val;
            },
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              //labelText: 'Email',
              hintText: 'Enter email address',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: TextFormField(
            obscureText: !_visiblePassword,
            keyboardType: TextInputType.visiblePassword,
            validator: _validatePassword,
            textInputAction: TextInputAction.done,
            onChanged: (val) {
              _password = val;
            },
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              //labelText: 'Password',
              hintText: 'Enter password',
              suffixIcon: InkWell(
                onTap: () {
                  setState(() {
                    _visiblePassword = !_visiblePassword;
                  });
                },
                child: Icon(
                  _visiblePassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
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
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Don\'t have an account?',
                  style: Theme.of(context).textTheme.bodySmall),
              TextButton(
                child:
                    const Text('Signup', style: TextStyle(color: Colors.blue)),
                onPressed: _onSignup,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onSignIn() async {
    if (!_formKey.currentState!.validate()) {
      // setState(() {
      //   _error = 'Please provide a valid email/password combination';
      // });
    } else {
      try {
        if (await AccountAuthentication.signIn(_email!, _password!)) {
          Navigator.pushNamedAndRemoveUntil(
              context, Routing.home, (Route<dynamic> route) => false);
        } else {
          showError(context, 'An error occured while signing in.');
        }
      } on Exception catch (e) {
        showError(context, e.toString());
      }
      // setState(() {
      //   _error = '';
      // });
    }
  }

  void _onSignup() {
    Navigator.pushNamedAndRemoveUntil(
        context, Routing.signup, (Route<dynamic> route) => false);
  }

  Future<void> _signInWithGoogle() async {
    try {
      if (await AccountAuthentication.authenticateWithGoogleSignIn()) {
        Navigator.pushNamedAndRemoveUntil(
            context, Routing.home, (Route<dynamic> route) => false);
      } else {
        showError(context, 'An error occured while signing in.');
      }
    } on Exception catch (e) {
      showError(context, e.toString());
    }
  }

  String? _emailValidator(String? email) {
    if (email != null && isEmail(email)) {
      return null;
    }

    return 'Invalid email address';
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Empty password';
    }

    return null;
  }
}
