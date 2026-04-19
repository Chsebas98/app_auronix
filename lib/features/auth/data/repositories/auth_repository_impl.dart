import 'package:auronix_app/app/database/auth_local_db_datasource.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auronix_app/features/auth/data/datasources/auth_local_services.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_request.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_verify_request.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class AuthRepositoryUnifiedImpl implements AuthUnifiedRepository {
  final AuthRemoteDatasource _remote;
  final AuthLocalDbDataSource _clientDb;
  final AuthLocalDbDataSource _driverDb;
  final AuthLocalServices _local;
  final RxSharedPreferences _prefs;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  AuthRepositoryUnifiedImpl({
    required AuthRemoteDatasource remote,
    required AuthLocalDbDataSource clientDb,
    required AuthLocalDbDataSource driverDb,
    required AuthLocalServices local,
    required RxSharedPreferences prefs,
  }) : _remote = remote,
       _clientDb = clientDb,
       _driverDb = driverDb,
       _local = local,
       _prefs = prefs;

  // ──────────────────── LOCAL ────────────────────

  @override
  Future<void> setRemember(bool value) => _local.setRememberMe(value);

  @override
  Future<bool> getRemember() => _local.getRememberMe();

  // ──────────────────── CLIENT ────────────────────

  @override
  Future<Either<Failure, AuthenticationCredentials>> loginClient({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      debugPrint('🔐 [AuthUnified] Iniciando login cliente: $email');

      final response = await _remote.loginClient(
        email: email,
        password: password,
      );

      if (!response['response']) {
        return Left(
          AuthFailure(
            message: response['message'] ?? 'Error al iniciar sesión',
            detail: response['errorDetail'],
            statusCode: response['statusCode'],
          ),
        );
      }

      final result = response['result'] as Map<String, dynamic>;
      final credsResult = _credsFromResult(result);
      if (credsResult.isLeft()) return credsResult;

      final creds = credsResult.getOrElse(
        () => const AuthenticationCredentials.empty(),
      );

      await _clientDb.saveUser(creds);
      await _local.setRememberMe(rememberMe);

      debugPrint('✅ [AuthUnified] Login cliente completado');
      return Right(creds);
    } catch (e) {
      debugPrint('❌ [AuthUnified] Error en login cliente: $e');
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al iniciar sesión',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthenticationCredentials>> loginWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      final googleAccount = await _googleSignIn.authenticate();
      final googleAuth = googleAccount.authentication;

      if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
        return const Left(
          AuthFailure(message: 'El token no se obtuvo correctamente'),
        );
      }

      final (firstName, lastName) = ResponseHelpers.compoundNamesGoogle(
        googleAccount.displayName ?? '',
      );

      final authModel = AuthenticationCredentials(
        tokenRefresh: '',
        tokenAccess: googleAuth.idToken!,
        role: Roles.rolUser,
        username: '',
        firstName: firstName,
        secondName: '',
        lastName: lastName ?? '',
        secondlastName: '',
        email: googleAccount.email,
        photoUrl: googleAccount.photoUrl ?? '',
        isGoogleUser: true,
      );

      await _clientDb.saveUser(authModel);
      return Right(authModel);
    } catch (e) {
      return Left(
        AuthFailure(
          message: 'Error al iniciar sesión con Google',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthenticationCredentials>> loginOrRegisterWithGoogle(
    AuthenticationCredentials googleCreds,
  ) async {
    try {
      debugPrint('🔐 [AuthUnified] Google login con backend');

      final response = await _remote.googleLogin(googleCreds);

      if (!response['response']) {
        return Left(
          AuthFailure(
            message: response['message'] ?? 'Error de autenticación',
            detail: response['errorDetail'],
            statusCode: response['statusCode'],
          ),
        );
      }

      final result = response['result'] as Map<String, dynamic>;
      final tokenAccess = result['token_access'] as String?;
      final tokenRefresh = result['token_refresh'] as String?;
      final userData = result['user'] as Map<String, dynamic>?;

      if (tokenAccess == null || tokenRefresh == null || userData == null) {
        return const Left(
          ServerFailure(
            message: 'Respuesta inválida del servidor',
            detail: 'Tokens o datos de usuario faltantes',
            statusCode: 500,
          ),
        );
      }

      final creds = googleCreds.copyWith(
        tokenAccess: tokenAccess,
        tokenRefresh: tokenRefresh,
        username: userData['username'] as String? ?? '',
      );

      await _clientDb.saveUser(creds);
      await _local.setRememberMe(true);

      debugPrint('✅ [AuthUnified] Google login/registro completado');
      return Right(creds);
    } catch (e) {
      debugPrint('❌ [AuthUnified] Error en Google login: $e');
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al iniciar sesión con Google',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> verifyRegister(
    RegisterVerifyRequest registerData,
  ) async {
    try {
      final response = await _remote.verifyRegisterClient(
        email: registerData.email,
        password: registerData.password,
        rol: RoleHelpers.getMnemonicoByRole(registerData.rol),
      );

      if (!response['response']) {
        return Left(
          ServerFailure(
            message: response['message'] ?? 'Error en la verificación',
            detail: response['errorDetail'],
            statusCode: response['statusCode'],
          ),
        );
      }

      return const Right(null);
    } catch (e) {
      debugPrint('❌ [AuthUnified] Error en verifyRegister: $e');
      return Left(
        UnexpectedFailure(
          message: 'Error al verificar usuario',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthenticationCredentials>> registerClient(
    RegisterRequest registerData,
  ) async {
    try {
      debugPrint('[AuthUnified] Iniciando registro de cliente');

      final names = ResponseHelpers.parseFullName(registerData.nombre1);
      final sendData = registerData
          .copyWithNames(
            nombre1: names.firstName,
            nombre2: names.secondName,
            ape1: names.lastName,
            ape2: names.secondLastName,
          )
          .toJson();

      final response = await _remote.registerClient(sendData);

      if (!response['response']) {
        return Left(
          ServerFailure(
            message: response['message'] ?? 'Error en el registro',
            detail: response['errorDetail'],
            statusCode: response['statusCode'],
          ),
        );
      }

      final result = response['result'] as Map<String, dynamic>;
      final credsResult = _credsFromResult(result);
      if (credsResult.isLeft()) return credsResult;

      final creds = credsResult.getOrElse(
        () => const AuthenticationCredentials.empty(),
      );

      await _clientDb.saveUser(creds);
      await _local.setRememberMe(false);

      debugPrint('✅ [AuthUnified] Registro cliente completado');
      return Right(creds);
    } catch (e) {
      debugPrint('❌ [AuthUnified] Error en registerClient: $e');
      return Left(
        UnexpectedFailure(
          message: 'Error al registrar usuario',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthenticationCredentials?>> getClientSession() async {
    try {
      final user = await _clientDb.readUser();
      if (user == null || user.tokenAccess.isEmpty) {
        if (user != null) await _clientDb.clear();
        return const Right(null);
      }
      return Right(user);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Error al obtener sesión de cliente',
          detail: e.toString(),
        ),
      );
    }
  }

  // ──────────────────── DRIVER ────────────────────

  @override
  Future<Either<Failure, AuthenticationCredentials>> loginDriver({
    required String ciPassport,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      debugPrint('🔐 [AuthUnified] Iniciando login conductor');

      final response = await _remote.loginDriver(
        ciPassport: ciPassport,
        password: password,
      );

      if (!response['response']) {
        return Left(
          AuthFailure(
            message: response['message'] ?? 'Error al iniciar sesión',
            detail: response['errorDetail'],
            statusCode: response['statusCode'],
          ),
        );
      }

      final result = response['result'] as Map<String, dynamic>;
      final credsResult = _conductorCredsFromResult(result, ciPassport);
      if (credsResult.isLeft()) return credsResult;

      final creds = credsResult.getOrElse(
        () => const AuthenticationCredentials.empty(),
      );

      await _driverDb.saveUser(creds);
      await _prefs.setBool(StaticVariables.rememberConductorKey, rememberMe);

      debugPrint('✅ [AuthUnified] Login conductor completado');
      return Right(creds);
    } catch (e) {
      debugPrint('❌ [AuthUnified] Error en login conductor: $e');
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al iniciar sesión',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthenticationCredentials>> registerDriver({
    required String ciPassport,
    required String password,
    required String email,
  }) async {
    try {
      debugPrint('[AuthUnified] Iniciando registro conductor');

      final response = await _remote.registerDriver(
        ciPassport: ciPassport,
        password: password,
        email: email,
      );

      if (!response['response']) {
        return Left(
          ServerFailure(
            message: response['message'] ?? 'Error en el registro',
            detail: response['errorDetail'],
            statusCode: response['statusCode'],
          ),
        );
      }

      final result = response['result'] as Map<String, dynamic>;
      final credsResult = _conductorCredsFromResult(result, ciPassport);
      if (credsResult.isLeft()) return credsResult;

      final creds = credsResult.getOrElse(
        () => const AuthenticationCredentials.empty(),
      );

      await _driverDb.saveUser(creds);

      debugPrint('✅ [AuthUnified] Registro conductor completado');
      return Right(creds);
    } catch (e) {
      debugPrint('❌ [AuthUnified] Error en registerDriver: $e');
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al registrar conductor',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthenticationCredentials?>> getDriverSession() async {
    try {
      final user = await _driverDb.readUser();
      if (user == null || user.tokenAccess.isEmpty) {
        if (user != null) await _driverDb.clear();
        return const Right(null);
      }
      return Right(user);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Error al obtener sesión de conductor',
          detail: e.toString(),
        ),
      );
    }
  }

  // ──────────────────── SHARED ────────────────────

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      debugPrint('🚪 [AuthUnified] Cerrando sesión...');

      final clientUser = await _clientDb.readUser();
      final driverUser = await _driverDb.readUser();

      await _clientDb.clear();
      await _driverDb.clear();
      await _local.clearSession();
      await _prefs.clear();

      if (_googleInitialized) await _googleSignIn.signOut();

      if (clientUser != null) {
        await _remote.closeSessionLogout(
          clientUser.email,
          RoleHelpers.getMnemonicoByRole(clientUser.role),
        );
      }
      if (driverUser != null) {
        await _remote.closeSessionLogout(
          driverUser.email,
          RoleHelpers.getMnemonicoByRole(driverUser.role),
        );
      }

      debugPrint('[AuthUnified] Sesión cerrada');
      return const Right(null);
    } catch (e) {
      await _clientDb.clear();
      await _driverDb.clear();
      await _local.clearSession();
      if (_googleInitialized) await _googleSignIn.signOut();
      return const Right(null);
    }
  }

  // ──────────────────── HELPERS ────────────────────

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  Either<Failure, AuthenticationCredentials> _credsFromResult(
    Map<String, dynamic> result,
  ) {
    final tokenAccess = result['token_access'] as String?;
    final tokenRefresh = result['token_refresh'] as String?;
    final userData = result['user'] as Map<String, dynamic>?;

    if (tokenAccess == null || tokenRefresh == null || userData == null) {
      return const Left(
        ServerFailure(
          message: 'Respuesta inválida del servidor',
          detail: 'Tokens o datos de usuario faltantes',
          statusCode: 500,
        ),
      );
    }

    return Right(
      AuthenticationCredentials(
        tokenAccess: tokenAccess,
        tokenRefresh: tokenRefresh,
        email: userData['email'] as String? ?? '',
        username: userData['username'] as String? ?? '',
        firstName: userData['nombre1'] as String? ?? '',
        lastName: userData['ape1'] as String? ?? '',
        secondName: userData['nombre2'] as String? ?? '',
        secondlastName: userData['ape2'] as String? ?? '',
        photoUrl: userData['photo_url'] as String? ?? '',
        role: RoleHelpers.mapRole(userData['role']),
      ),
    );
  }

  Either<Failure, AuthenticationCredentials> _conductorCredsFromResult(
    Map<String, dynamic> result,
    String ciPassport,
  ) {
    final tokenAccess = result['token_access'] as String?;
    final tokenRefresh = result['token_refresh'] as String?;
    final userData = result['user'] as Map<String, dynamic>?;

    if (tokenAccess == null || tokenRefresh == null || userData == null) {
      return const Left(
        ServerFailure(
          message: 'Respuesta inválida del servidor',
          detail: 'Tokens o datos de usuario faltantes',
          statusCode: 500,
        ),
      );
    }

    return Right(
      AuthenticationCredentials(
        tokenAccess: tokenAccess,
        tokenRefresh: tokenRefresh,
        email: userData['email'] as String? ?? '',
        username: userData['username'] as String? ?? ciPassport,
        firstName: userData['nombre1'] as String? ?? '',
        lastName: userData['ape1'] as String? ?? '',
        secondName: userData['nombre2'] as String? ?? '',
        secondlastName: userData['ape2'] as String? ?? '',
        photoUrl: userData['photo_url'] as String? ?? '',
        role: RoleHelpers.mapRole(userData['role']),
      ),
    );
  }
}
