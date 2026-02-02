import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/db_constants.dart';
import 'package:auronix_app/core/models/interfaces/core_enums.dart';
import 'package:auronix_app/features/features.dart';

class AuthLocalDbDataSource {
  final AppDatabase _db;
  AuthLocalDbDataSource(this._db);

  /// Guardar usuario completo (login/registro inicial)
  Future<void> saveUser(AuthenticationCredentials creds) {
    return _db.upsertUserMap({
      DbConstants.colTokenAccess: creds.tokenAccess,
      DbConstants.colTokenRefresh: creds.tokenRefresh,
      DbConstants.colRole: creds.role.name,
      DbConstants.colUsername: creds.username,
      DbConstants.colFirstName: creds.firstName,
      DbConstants.colSecondName:
          (creds.secondName is String && (creds.secondName as String).isEmpty)
          ? null
          : creds.secondName?.toString(),
      DbConstants.colLastName: creds.lastName,
      DbConstants.colSecondLastName: creds.secondlastName,
      DbConstants.colEmail: creds.email,
      DbConstants.colPhotoUrl: creds.photoUrl,
      DbConstants.colIsGoogleUser: creds.isGoogleUser ? 1 : 0,
      DbConstants.colTokenExpiresAt: DateTime.now()
          .add(const Duration(hours: 1))
          .millisecondsSinceEpoch,
    });
  }

  /// ✅ NUEVO: Actualizar solo tokens (después de refresh)
  Future<void> updateTokens({
    required String tokenAccess,
    required String tokenRefresh,
  }) {
    return _db.updateTokens(
      tokenAccess: tokenAccess,
      tokenRefresh: tokenRefresh,
    );
  }

  /// ✅ NUEVO: Obtener access token
  Future<String?> getAccessToken() => _db.getAccessToken();

  /// ✅ NUEVO: Obtener refresh token
  Future<String?> getRefreshToken() => _db.getRefreshToken();

  Future<AuthenticationCredentials?> readUser() async {
    final row = await _db.getUserMap();
    if (row == null) return null;

    return AuthenticationCredentials(
      tokenAccess: (row[DbConstants.colTokenAccess] as String),
      tokenRefresh: (row[DbConstants.colTokenRefresh] as String?) ?? '',
      role: Roles.values.byName(row[DbConstants.colRole] as String),
      username: (row[DbConstants.colUsername] as String?) ?? '',
      firstName: (row[DbConstants.colFirstName] as String),
      secondName: row[DbConstants.colSecondName] as String?,
      lastName: (row[DbConstants.colLastName] as String),
      secondlastName: (row[DbConstants.colSecondLastName] as String?) ?? '',
      email: (row[DbConstants.colEmail] as String?) ?? '',
      photoUrl: (row[DbConstants.colPhotoUrl] as String?) ?? '',
      isGoogleUser: (row[DbConstants.colIsGoogleUser] as int) == 1,
    );
  }

  Future<void> clear() => _db.clearUser();
}
