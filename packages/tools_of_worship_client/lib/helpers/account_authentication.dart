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
    if (isSignedIn) {
      return true;
    }

    // TODO: Implement refresh tokens. Use refresh token to get new auth token. Need auth token to get a refresh token.
    // Set a timer to use the refresh token to get a new Auth token every 12 minutes. Get a new refresh token every hour if remember signin is used.
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'signInToken');
    if (token != null) {
      return await _authenticate(SignInType.token, token, null);
    }

    return false;
  }

  Future<bool> signIn(String email, String password) async {
    return await _authenticate(SignInType.localUser, email, password);
  }

  Future<bool> authenticateWithGoogleSignIn() async {
    GoogleSignInHelper helper = GoogleSignInHelper();
    await helper.signIn();
    String? token = await helper.signInToken;
    if (token == null) {
      throw Exception('Could not retrieve google ID token.');
    }

    return await _authenticate(SignInType.googleSignIn, token, null);
  }

  Future<void> signOut() async {
    _authToken = null;
    _displayName = null;
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'signInToken');

    // This honestly seems weird. We may not have signed in with Google.
    GoogleSignInHelper helper = GoogleSignInHelper();
    await helper.signOut();
  }

  bool get isSignedIn => _authToken != null && _displayName != null;

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
