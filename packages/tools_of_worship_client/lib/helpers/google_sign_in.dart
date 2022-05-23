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
      //'email',
      //'openid',
      // 'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<String> signIn() async {
    try {
      await _googleSignIn.signIn();
      return 'OK';
    } catch (error) {
      return 'Error: $error';
    }
  }

  Future<void> autoSignIn() async {
    await _googleSignIn.signInSilently(suppressErrors: false);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<String?> get signInToken async {
    GoogleSignInAccount? acc = currentUser;
    if (acc == null) {
      return null;
    }

    return (await acc.authentication).idToken;
  }
}
