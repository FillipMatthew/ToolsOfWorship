import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_button/sign_button.dart';
import 'package:string_validator/string_validator.dart';
import 'package:tools_of_worship_client/pages/signup.dart';

import '../config/styling.dart';
import '../helpers/alertbox.dart';
import '../providers/account_authentication.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _visiblePassword = false;
  // String? _error;
  String? _email;
  String? _password;

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
        ),
        child: Card(
          elevation: 4.0,
          shape: const RoundedRectangleBorder(
            side: BorderSide.none,
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
            onPressed: _onSignIn,
            child: const Text('Sign In'),
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
                onPressed: _onSignup,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
                child:
                    const Text('Signup', style: TextStyle(color: Colors.blue)),
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
        context
            .read<AccountAuthentication>()
            .signIn(_email!, _password!)
            .then((success) {
          if (!success && context.mounted) {
            showError(context, 'An error occured while signing in.');
          }
        });
      } on Exception catch (e) {
        showError(context, e.toString());
      }
      // setState(() {
      //   _error = '';
      // });
    }
  }

  void _onSignup() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SignupPage()));
  }

  Future<void> _signInWithGoogle() async {
    try {
      context
          .read<AccountAuthentication>()
          .authenticateWithGoogleSignIn()
          .then((sucess) {
        if (!sucess && context.mounted) {
          showError(context, 'An error occured while signing in.');
        }
      });
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
