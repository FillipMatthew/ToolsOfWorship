enum AccessLevel {
  owner,
  admin,
  moderator,
  readAndWrite,
  readOnly;

  int toJson() => index;
  static AccessLevel fromJson(int json) => values[json];
}
