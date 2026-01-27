class DbConstants {
  static const String dbName = 'auronix.db';
  static const int dbVersion = 1;

  // Ojo: "user" puede ser confuso; en SQLite suele ir bien.
  // Si quieres ultra-safe: usa "users" o "app_user".
  static const String tableUser = 'user';

  static const String colId = 'id';
  static const String colToken = 'token';
  static const String colRole = 'role';
  static const String colUsername = 'username';
  static const String colFirstName = 'first_name';
  static const String colSecondName = 'second_name';
  static const String colLastName = 'last_name';
  static const String colSecondLastName = 'second_last_name';
  static const String colEmail = 'email';
  static const String colPhotoUrl = 'photo_url';
  static const String colIsGoogleUser = 'is_google_user';

  // Para garantizar 1 solo registro (tu “sesión” local).
  static const int singleUserId = 1;
}
