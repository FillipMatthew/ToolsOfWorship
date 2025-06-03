enum SignInType {
  none,
  token,
  localUser,
  googleSignIn;

  int toJson() => index;
  static fromJson(int json) => values[json];
}
