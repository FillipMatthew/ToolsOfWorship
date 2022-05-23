import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tools_of_worship_client/apis/types/sign_in_type.dart';
import 'package:tools_of_worship_client/apis/users.dart';
import 'package:tools_of_worship_client/helpers/google_sign_in.dart';

class AccountAuthentication {
  static String? _authToken;
  static String? _displayName;

  static String get authHeaderString =>
      _authToken != null ? 'Bearer $_authToken' : '';

  Future<bool> signInSilent() async {
    // TODO: Token based auto sign in and if that fails then try Google sign in.
    try {
      const storage = FlutterSecureStorage();
      String? value = await storage.read(key: "useGoogleSignIn");
      if (value != "true") {
        return false;
      }

      GoogleSignInHelper helper = GoogleSignInHelper();
      await helper.autoSignIn();
      if (helper.currentUser != null) {
        String? token = await helper.signInToken;
        if (token == null) {
          return false;
        }

        if (await _authenticate(SignInType.googleSignIn, token, null)) {
          await storage.write(key: "useGoogleSignIn", value: "true");
          return true;
        } else {
          await storage.delete(key: "useGoogleSignIn");
          return false;
        }
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  Future<bool> signIn(String email, String password) async {
    return await _authenticate(SignInType.localUser, email, password);
  }

  Future<bool> authenticateWithGoogleSignIn() async {
    GoogleSignInHelper helper = GoogleSignInHelper();
    await helper.signIn();
    if (helper.currentUser != null) {
      String? token = await helper.signInToken;
      if (token == null) {
        throw Exception('Could not retrieve google ID token');
      }

      if (await _authenticate(SignInType.googleSignIn, token, null)) {
        const storage = FlutterSecureStorage();
        await storage.write(key: "useGoogleSignIn", value: "true");
        return true;
      } else {
        const storage = FlutterSecureStorage();
        await storage.delete(key: 'useGoogleSignIn');
        return false;
      }
    }

    throw Exception('An error occured while signing in.');
  }

  Future<void> signOut() async {
    GoogleSignInHelper helper = GoogleSignInHelper();
    await helper.signOut();
    _authToken = null;
    _displayName = null;
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'useGoogleSignIn');
  }

  String get displayName => _displayName ?? '';

  Future<bool> _authenticate(
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
