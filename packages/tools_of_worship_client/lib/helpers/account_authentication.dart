import 'package:tools_of_worship_client/apis/types/sign_in_type.dart';
import 'package:tools_of_worship_client/apis/users.dart';
import 'package:tools_of_worship_client/helpers/google_sign_in.dart';

class AccountAuthentication {
  static String? _authToken;
  static String? _displayName;

  static String get authHeaderString =>
      _authToken != null ? 'Bearer $_authToken' : '';

  static Future<bool> signInSilent() async {
    // TODO: Token based auto sign in and if that fails then try Google sign in.
    try {
      GoogleSignInHelper helper = GoogleSignInHelper();
      await helper.autoSignIn();
      if (helper.currentUser != null) {
        String? token = await helper.signInToken;
        if (token == null) {
          return false;
        }

        return await _authenticate(SignInType.googleSignIn, token, null);
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  static Future<bool> signIn(String userName, String password) async {
    return _authenticate(SignInType.localUser, userName, password);
  }

  static Future<bool> authenticateWithGoogleSignIn() async {
    GoogleSignInHelper helper = GoogleSignInHelper();
    await helper.signIn();
    if (helper.currentUser != null) {
      String? token = await helper.signInToken;
      if (token == null) {
        throw Exception('Could not retrieve google ID token');
      }

      return _authenticate(SignInType.googleSignIn, token, null);
    }

    throw Exception('An error occured while signing in.');
  }

  static Future<void> signOut() async {
    GoogleSignInHelper helper = GoogleSignInHelper();
    await helper.signOut();
    _authToken = null;
    _displayName = null;
  }

  static String get displayName => _displayName ?? '';

  static Future<bool> _authenticate(
      int signInType, String accountId, String? password) async {
    Map<String, String> userData =
        await ApiUsers.authenticate(signInType, accountId, password);

    _authToken = userData['token'];
    _displayName = userData['displayName'];
    if (_authToken != null) {
      return true;
    } else {
      return false;
    }
  }
}
