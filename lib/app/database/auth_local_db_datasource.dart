import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/db_constants.dart';
import 'package:auronix_app/core/interfaces/core_enums.dart';
import 'package:auronix_app/features/features.dart';

class AuthLocalDbDataSource {
  final AppDatabase _db;
  AuthLocalDbDataSource(this._db);

  Future<void> saveUser(AuthenticationCredentials creds) {
    return _db.upsertUserMap({
      DbConstants.colToken: creds.token,
      DbConstants.colRole: creds.role.name, // o creds.role.toString()
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
    });
  }

  Future<AuthenticationCredentials?> readUser() async {
    final row = await _db.getUserMap();
    if (row == null) return null;

    return AuthenticationCredentials(
      token: (row[DbConstants.colToken] as String),
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
