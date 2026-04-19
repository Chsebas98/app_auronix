class DbConstants {
  static const String dbName = 'auronix.db';
  static const int dbVersion = 3;

  static const String tableUser = 'user';

  // Columnas
  static const String colId = 'id';
  static const String colUserType = 'user_type';
  static const String colTokenAccess = 'token_access';
  static const String colTokenRefresh = 'token_refresh';
  static const String colRole = 'role';
  static const String colUsername = 'username';
  static const String colFirstName = 'first_name';
  static const String colSecondName = 'second_name';
  static const String colLastName = 'last_name';
  static const String colSecondLastName = 'second_last_name';
  static const String colEmail = 'email';
  static const String colPhotoUrl = 'photo_url';
  static const String colIsGoogleUser = 'is_google_user';
  static const String colTokenExpiresAt = 'token_expires_at';
  static const String colCreatedAt = 'created_at';

  static const String userTypeClient = 'CLIENT';
  static const String userTypeDriver = 'DRIVER';
}
