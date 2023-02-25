import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:string_validator/string_validator.dart';
import 'package:tools_of_worship_api/tools_of_worship_client_api.dart';
import 'package:tools_of_worship_client/pages/login.dart';

import '../config/styling.dart';
import '../helpers/alertbox.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _visiblePassword = false;
  // String? _error;
  String? _displayName;
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
    //bool bDark = Theme.of(context).colorScheme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: TextFormField(
            keyboardType: TextInputType.name,
            validator: _displayNameValidator,
            textInputAction: TextInputAction.next,
            onChanged: (val) {
              _displayName = val;
            },
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              //labelText: 'Full name',
              hintText: 'Enter full name',
            ),
          ),
        ),
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
            onPressed: _onSignup,
            child: const Text('Sign Up'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account?',
                  style: Theme.of(context).textTheme.bodySmall),
              TextButton(
                onPressed: _onBackToSignin,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
                child:
                    const Text('Sign in', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onSignup() async {
    if (!_formKey.currentState!.validate()) {
      // setState(() {
      //   _error = 'Please complete the form to continue signup.';
      // });
    } else {
      ApiUsers apiUsers = context.read<ApiUsers>();

      if (await apiUsers.signup(_displayName!, _email!, _password!)) {
        if (context.mounted) {
          Navigator.of(context).pop();
          showMessage(context,
              'Please check your email account. You need to verify your email address before you can continue.');
        }
      } else {
        if (context.mounted) {
          showError(context, 'An error occured while signing up.');
        }
        // setState(() {
        //   _error = '';
        // });
      }
    }
  }

  void _onBackToSignin() {
    Navigator.of(context).pop();
  }

  String? _displayNameValidator(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return 'Empty name';
    }

    return null;
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

    if (!isLength(password, 8)) {
      return 'Password must to be 8 or more characters long';
    }

    return null;
  }
}
