import 'package:auronix_app/app/core/services/secure_storage_service.dart';
import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/db_constants.dart';
import 'package:auronix_app/core/models/interfaces/core_enums.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';

class AuthLocalDbDataSource {
  final AppDatabase _db;
  final SecureStorageService _secureStorage;
  final String userType;

  AuthLocalDbDataSource(
    this._db,
    this._secureStorage, {
    required this.userType,
  });

  /// Guardar usuario completo (login/registro inicial)
  Future<void> saveUser(AuthenticationCredentials creds) async {
    await _secureStorage.saveTokens(
      accessToken: creds.tokenAccess,
      refreshToken: creds.tokenRefresh,
      userType: userType,
    );

    await _db.upsertUserMap({
      DbConstants.colTokenAccess: '',
      DbConstants.colTokenRefresh: '',
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
    }, userType);
  }

  /// Actualizar solo tokens (después de refresh)
  Future<void> updateTokens({
    required String tokenAccess,
    required String tokenRefresh,
  }) {
    return _secureStorage.saveTokens(
      accessToken: tokenAccess,
      refreshToken: tokenRefresh,
      userType: userType,
    );
  }

  /// Obtener access token
  Future<String?> getAccessToken() => _secureStorage.getAccessToken();

  /// Obtener refresh token
  Future<String?> getRefreshToken() => _secureStorage.getRefreshToken();

  Future<AuthenticationCredentials?> readUser() async {
    final row = await _db.getUserMap(userType);
    if (row == null) return null;

    final accessToken = await _secureStorage.getAccessToken();
    final refreshToken = await _secureStorage.getRefreshToken();

    return AuthenticationCredentials(
      tokenAccess: accessToken ?? '',
      tokenRefresh: refreshToken ?? '',
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

  Future<void> clear() async {
    await Future.wait([
      _db.clearUser(userType),
      _secureStorage.clearTokens(),
    ]);
  }
}
