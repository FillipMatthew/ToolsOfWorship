import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInHelper {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '390448088945-mbbpdipsvt5ff6u3rv4ft6humf3dqm4s.apps.googleusercontent.com',
    scopes: [
      // Google OAuth2 API, v2
      // 'openid',
      // 'https://www.googleapis.com/auth/userinfo.email',
      // 'https://www.googleapis.com/auth/userinfo.profile',
      // Google Sign-In
      'profile',
      'email',
      //'openid',
      // 'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<bool> signIn() async {
    return (await _googleSignIn.signIn()) != null;
  }

  Future<void> authenticate() async {
    await _googleSignIn.signInSilently(
        reAuthenticate: true, suppressErrors: false);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<String?> get signInToken async =>
      (await _googleSignIn.currentUser?.authentication)?.idToken;
}
