import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import 'package:tools_of_worship_client/apis/users.dart';
import 'package:tools_of_worship_client/tools_of_worship_client.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
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
                  _visiblePassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: ElevatedButton(
            child: const Text('Sign Up'),
            onPressed: _onSignup,
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
                child:
                    const Text('Sign in', style: TextStyle(color: Colors.blue)),
                onPressed: _onBackToSignin,
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

  Future<void> _onSignup() async {
    if (!_formKey.currentState!.validate()) {
      // setState(() {
      //   _error = 'Please complete the form to continue signup.';
      // });
    } else {
      if (!await ApiUsers.signup(_displayName!, _email!, _password!)) {
        Navigator.pushNamedAndRemoveUntil(
            context, Routing.root, (Route<dynamic> route) => false);
        showMessage(context,
            'Please check your email account. You need to verify your email address before you can continue.');
      } else {
        // setState(() {
        //   _error = '';
        // });
      }
    }
  }

  void _onBackToSignin() {
    Navigator.pushNamedAndRemoveUntil(
        context, Routing.root, (Route<dynamic> route) => false);
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

    if (isLength(password, 8)){
      return 'Password must to be 8 or more characters long';
    }

    return null;
  }
}
