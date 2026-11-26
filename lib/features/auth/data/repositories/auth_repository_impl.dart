import 'package:auronix_app/app/core/network/secure_storage_service.dart';
import 'package:auronix_app/app/database/auth_local_db_datasource.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/app/environments/flavors/env_dev_config.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:auronix_app/features/auth/data/models/auth_response_model.dart';
import 'package:auronix_app/features/auth/data/models/login_request_model.dart';
import 'package:auronix_app/features/auth/data/models/register_request_model.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auronix_app/features/auth/data/datasources/auth_local_services.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_driver_request.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_request.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_verify_request.dart';
import 'package:auronix_app/features/auth/domain/models/user_data.dart';
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
  final SecureStorageService _secureStorage;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  AuthRepositoryUnifiedImpl({
    required AuthRemoteDatasource remote,
    required AuthLocalDbDataSource clientDb,
    required AuthLocalDbDataSource driverDb,
    required AuthLocalServices local,
    required RxSharedPreferences prefs,
    required SecureStorageService secureStorage,
  }) : _remote = remote,
       _clientDb = clientDb,
       _driverDb = driverDb,
       _local = local,
       _prefs = prefs,
       _secureStorage = secureStorage;

  // ──────────────────── Backend real (T11) ────────────────────

  @override
  Future<Either<Failure, UserData>> loginWithBackend({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remote.login(
        LoginRequestModel(email: email, password: password),
      );
      final persisted = await _persistBackendTokens(response);
      if (persisted != null) return Left(persisted);
      return Right(response.toUserData());
    } on AuthRequestException catch (e) {
      return Left(e.failure);
    }
  }

  @override
  Future<Either<Failure, UserData>> registerWithBackend(
    RegisterRequestModel data,
  ) async {
    try {
      await _remote.register(data);
      // El registro no devuelve tokens (RegisterUserResponseDto no los trae)
      // — hace falta un login aparte despues de registrar.
      return await loginWithBackend(email: data.email, password: data.password);
    } on AuthRequestException catch (e) {
      return Left(e.failure);
    }
  }

  Future<Failure?> _persistBackendTokens(AuthResponseModel response) async {
    final savedAccess = await _secureStorage.saveAccessToken(
      response.accessToken,
    );
    if (savedAccess.isLeft()) {
      return savedAccess.fold((f) => f, (_) => null);
    }
    final savedRefresh = await _secureStorage.saveRefreshToken(
      response.refreshToken,
    );
    return savedRefresh.fold((f) => f, (_) => null);
  }

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
      await _prefs.setString(StaticVariables.lastActiveRole, 'CLIENT');

      debugPrint('[AuthUnified] Login cliente completado');
      return Right(creds);
    } catch (e) {
      debugPrint('[AuthUnified] Error en login cliente: $e');
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
      debugPrint('[AuthUnified] GoogleSignIn inicializado');

      final googleAccount = await _googleSignIn.authenticate();
      debugPrint('[AuthUnified] Google account obtenida: $googleAccount');
      final googleAuth = googleAccount.authentication;
      debugPrint('[AuthUnified] Google authentication obtenida: $googleAuth');
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
        username: googleAccount.id,
        firstName: firstName,
        secondName: '',
        lastName: lastName ?? '',
        secondlastName: '',
        email: googleAccount.email,
        photoUrl: googleAccount.photoUrl ?? '',
        isGoogleUser: true,
      );
      debugPrint('[AuthUnified] Credenciales Google obtenidas: $authModel');
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
        final statusCode = response['statusCode'] as int?;
        // T11: el backend real (micro-auronix AuthController) todavia no
        // tiene un endpoint de intercambio Google->JWT — un 404 aqui no es
        // "credenciales invalidas", es que falta implementarlo. TODO T11:
        // una vez el backend agregue ese endpoint, este caso especial sobra.
        if (statusCode == 404) {
          return const Left(
            UnexpectedFailure(
              message:
                  'Inicio de sesión con Google no disponible todavía: '
                  'el servidor no tiene este endpoint implementado.',
              detail: 'POST /auth/clients/google-login -> 404',
            ),
          );
        }
        return Left(
          AuthFailure(
            message: response['message'] ?? 'Error de autenticación',
            detail: response['errorDetail'],
            statusCode: statusCode,
          ),
        );
      }

      final result = response['result'] as Map<String, dynamic>;
      final tokenAccess = result['token_access'] as String?;
      final tokenRefresh = result['token_refresh'] as String?;

      if (tokenAccess == null || tokenRefresh == null) {
        return const Left(
          ServerFailure(
            message: 'Respuesta inválida del servidor',
            detail: 'Tokens faltantes en la respuesta',
            statusCode: 500,
          ),
        );
      }

      final creds = googleCreds.copyWith(
        tokenAccess: tokenAccess,
        tokenRefresh: tokenRefresh,
        username: result['username'] as String? ?? googleCreds.username,
      );

      await _clientDb.saveUser(creds);
      await _local.setRememberMe(true);
      await _prefs.setString(StaticVariables.lastActiveRole, 'CLIENT');

      debugPrint('[AuthUnified] Google login/registro completado');
      return Right(creds);
    } catch (e) {
      debugPrint('[AuthUnified] Error en Google login: $e');
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
      debugPrint('[AuthUnified] Error en verifyRegister: $e');
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

      debugPrint('[AuthUnified] Registro cliente completado');
      return Right(creds);
    } catch (e) {
      debugPrint('[AuthUnified] Error en registerClient: $e');
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

  @override
  Future<Either<Failure, AuthenticationCredentials>>
  completeRegisterClient() async {
    try {
      debugPrint('[AuthUnified] Completando registro de cliente');
      // Aquí podrías hacer una llamada al backend para completar el registro
      return const Right(AuthenticationCredentials.empty());
    } catch (e) {
      debugPrint('[AuthUnified] Error en completeRegisterClient: $e');
      return Left(
        UnexpectedFailure(
          message: 'Error al completar registro',
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
        identificacion: ciPassport,
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
      await _prefs.setString(StaticVariables.lastActiveRole, 'DRIVER');

      debugPrint('[AuthUnified] Login conductor completado');
      return Right(creds);
    } catch (e) {
      debugPrint('[AuthUnified] Error en login conductor: $e');
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al iniciar sesión',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthenticationCredentials>> registerDriver(
    RegisterDriverRequest data,
  ) async {
    try {
      debugPrint('[AuthUnified] Iniciando registro conductor');

      final response = await _remote.registerDriver(data.toJson());

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
      final credsResult = _conductorCredsFromResult(result, data.cedula);
      if (credsResult.isLeft()) return credsResult;

      final creds = credsResult.getOrElse(
        () => const AuthenticationCredentials.empty(),
      );

      await _driverDb.saveUser(creds);

      debugPrint('[AuthUnified] Registro conductor completado');
      return Right(creds);
    } catch (e) {
      debugPrint('[AuthUnified] Error en registerDriver: $e');
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

  // Web OAuth client IDs (type 3) extraídos de google-services.json por flavor.
  // Requerido por google_sign_in v7.x: Credential Manager en Android necesita
  // serverClientId para emitir el ID token. Sin él lanza GetCredentialResponse error.
  static const _devServerClientId =
      '451995583792-urgesf9bm8hfi60vvvvaehibft822usp.apps.googleusercontent.com';
  static const _prodServerClientId =
      '820427140460-mhlc0400lsqh7oimeo0ivp0u9j9egm2d.apps.googleusercontent.com';

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    final serverClientId = Environment().config is EnvDevConfig
        ? _devServerClientId
        : _prodServerClientId;
    await _googleSignIn.initialize(serverClientId: serverClientId);
    _googleInitialized = true;
  }

  Either<Failure, AuthenticationCredentials> _credsFromResult(
    Map<String, dynamic> result,
  ) {
    final tokenAccess = result['token_access'] as String?;
    final tokenRefresh = result['token_refresh'] as String?;

    if (tokenAccess == null || tokenRefresh == null) {
      return const Left(
        ServerFailure(
          message: 'Respuesta inválida del servidor',
          detail: 'Tokens faltantes en la respuesta',
          statusCode: 500,
        ),
      );
    }

    return Right(
      AuthenticationCredentials(
        tokenAccess: tokenAccess,
        tokenRefresh: tokenRefresh,
        email: result['email'] as String? ?? '',
        username: result['username'] as String? ?? '',
        firstName: result['first_name'] as String? ?? '',
        secondName: result['second_name'] as String? ?? '',
        lastName: result['last_name'] as String? ?? '',
        secondlastName: result['second_last_name'] as String? ?? '',
        photoUrl: result['photo_url'] as String? ?? '',
        role: RoleHelpers.mapRole(result['role']),
      ),
    );
  }

  Either<Failure, AuthenticationCredentials> _conductorCredsFromResult(
    Map<String, dynamic> result,
    String ciPassport,
  ) {
    debugPrint('[AuthUnified] driver result keys: ${result.keys.toList()}');
    debugPrint('[AuthUnified] driver role raw: ${result['role']}');

    final tokenAccess = result['token_access'] as String?;
    final tokenRefresh = result['token_refresh'] as String?;

    if (tokenAccess == null || tokenRefresh == null) {
      return const Left(
        ServerFailure(
          message: 'Respuesta inválida del servidor',
          detail: 'Tokens faltantes en la respuesta',
          statusCode: 500,
        ),
      );
    }

    return Right(
      AuthenticationCredentials(
        tokenAccess: tokenAccess,
        tokenRefresh: tokenRefresh,
        email: result['email'] as String? ?? '',
        username: result['username'] as String? ?? ciPassport,
        firstName: result['first_name'] as String? ?? '',
        secondName: result['second_name'] as String? ?? '',
        lastName: result['last_name'] as String? ?? '',
        secondlastName: result['second_last_name'] as String? ?? '',
        photoUrl: result['photo_url'] as String? ?? '',
        role: RoleHelpers.mapRole(result['role']),
      ),
    );
  }
}
