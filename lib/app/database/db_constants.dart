class DbConstants {
  static const String dbName = 'auronix.db';
  static const int dbVersion = 2; //

  static const String tableUser = 'user';

  // Columnas existentes
  static const String colId = 'id';
  static const String colTokenAccess = 'token_access'; // RENOMBRAR
  static const String colTokenRefresh = 'token_refresh'; // NUEVO
  static const String colRole = 'role';
  static const String colUsername = 'username';
  static const String colFirstName = 'first_name';
  static const String colSecondName = 'second_name';
  static const String colLastName = 'last_name';
  static const String colSecondLastName = 'second_last_name';
  static const String colEmail = 'email';
  static const String colPhotoUrl = 'photo_url';
  static const String colIsGoogleUser = 'is_google_user';
  static const String colTokenExpiresAt = 'token_expires_at'; // NUEVO
  static const String colCreatedAt = 'created_at'; // NUEVO

  static const int singleUserId = 1;
}
