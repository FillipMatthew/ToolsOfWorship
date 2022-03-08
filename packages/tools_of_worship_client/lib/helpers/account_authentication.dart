import 'package:tools_of_worship_client/apis/types/sign_in_type.dart';
import 'package:tools_of_worship_client/apis/users.dart';
import 'package:tools_of_worship_client/helpers/google_sign_in.dart';

class AccountAuthentication {
  static String? _authToken;

  static Future<String?> signInSilent() async {
    // TODO: Token based auto sign in and if that fails then try Google sign in.
    try {
      GoogleSignInHelper helper = GoogleSignInHelper();
      await helper.autoSignIn().then((value) async {
        if (helper.currentUser != null) {
          String? token = await helper.signInToken;
          if (token == null) {
            return null;
          }

          return _authenticate(SignInType.googleSignIn, token, null);
        }
      });
    } catch (_) {
      return null;
    }

    return null;
  }

  static Future<String?> signIn(String userName, String password) async {
    return _authenticate(SignInType.localUser, userName, password);
  }

  static Future<String?> authenticateWithGoogleSignIn() async {
    GoogleSignInHelper helper = GoogleSignInHelper();
    helper.signIn().then((value) async {
      if (helper.currentUser != null) {
        String? token = await helper.signInToken;
        if (token == null) {
          throw Exception('Could not retrieve google ID token');
        }
        return _authenticate(SignInType.googleSignIn, token, null);
      } else {
        throw Exception('An error occured while signing in.');
      }
    });

    return null;
  }

  static Future<String?> _authenticate(
      int signInType, String accountIdentifier, String? password) async {
    String? token =
        await ApiUsers.authenticate(signInType, accountIdentifier, password);
    if (token == null) {
      return null;
    } else {
      _authToken = token;
      return _authToken;
    }
  }
}
