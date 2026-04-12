import 'package:auronix_app/app/database/auth_local_db_datasource.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/features.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalServices local;
  final AuthLocalDbDataSource localDb;
  final AuthenticationService authenticationService;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final RxSharedPreferences _prefs = sl<RxSharedPreferences>();
  bool _googleInitialized = false;

  AuthRepositoryImpl({
    required this.local,
    required this.localDb,
    required this.authenticationService,
  });

  //?LOCAL
  @override
  Future<void> setRemember(bool value) async {
    await local.setRememberMe(value);
  }

  @override
  Future<bool> getRemember() async {
    return await local.getRememberMe();
  }

  //?REMOTAS

  @override
  Future<Either<Failure, AuthenticationCredentials>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      debugPrint('🔐 Iniciando login con credenciales');
      debugPrint('📧 Email: $email');

      final response = await authenticationService.loginUser(
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

      final creds = AuthenticationCredentials(
        tokenAccess: tokenAccess,
        tokenRefresh: tokenRefresh,
        email: userData['email'] as String,
        username: userData['username'] as String,
        firstName: userData['nombre1'] as String? ?? '',
        lastName: userData['ape1'] as String? ?? '',
        secondName: userData['nombre2'] as String? ?? '',
        secondlastName: userData['ape2'] as String? ?? '',
        photoUrl: userData['photo_url'] as String? ?? '',
        role: RoleHelpers.mapRole(userData['role']),
      );

      await localDb.saveUser(creds);
      await local.setRememberMe(rememberMe);

      debugPrint('✅ Login completado');
      debugPrint('🔑 Access Token: ${tokenAccess.substring(0, 20)}...');
      debugPrint('🔄 Refresh Token: ${tokenRefresh.substring(0, 20)}...');

      return Right(creds);
    } catch (e) {
      debugPrint('❌ Error en login: $e');
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al iniciar sesión',
          detail: e.toString(),
        ),
      );
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  @override
  Future<Either<Failure, AuthenticationCredentials>> loginWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      final googleAccount = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth =
          googleAccount.authentication;
      debugPrintStack(label: 'Google Auth: ${googleAuth.idToken}');
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

      await localDb.saveUser(authModel);
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
      debugPrint('🔐 Iniciando login/registro con Google + Backend');
      debugPrint('📧 Email: ${googleCreds.email}');

      final response = await authenticationService.googleLogin(googleCreds);

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
        username: userData['username'] as String,
      );

      await localDb.saveUser(creds);
      await local.setRememberMe(true);

      debugPrint('✅ Login/Registro completado');
      debugPrint('🔑 Access Token: ${tokenAccess.substring(0, 20)}...');
      debugPrint('🔄 Refresh Token: ${tokenRefresh.substring(0, 20)}...');

      return Right(creds);
    } catch (e) {
      debugPrint('❌ Error en loginOrRegisterWithGoogle: $e');
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
      final response = await authenticationService.verifyRegister(
        registerData: registerData,
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
      debugPrint('❌ Error en verifyRegister: $e');
      return Left(
        UnexpectedFailure(
          message: 'Error al verificar usuario',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthenticationCredentials>> registerUser(
    RegisterRequest registerData,
  ) async {
    try {
      debugPrint('Iniciando registro de usuario');
      final names = ResponseHelpers.parseFullName(registerData.nombre1);

      final sendDataRegister = registerData.copyWithNames(
        nombre1: names.firstName,
        nombre2: names.secondName,
        ape1: names.lastName,
        ape2: names.secondLastName,
      );

      debugPrint('Datos a enviar para registro: $sendDataRegister');
      final response = await authenticationService.register(
        registerData: sendDataRegister,
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

      final creds = AuthenticationCredentials(
        tokenAccess: tokenAccess,
        tokenRefresh: tokenRefresh,
        email: userData['email'] as String,
        username: userData['username'] as String,
        firstName: userData['nombre1'] as String? ?? '',
        lastName: userData['ape1'] as String? ?? '',
        secondName: userData['nombre2'] as String? ?? '',
        secondlastName: userData['ape2'] as String? ?? '',
        photoUrl: userData['photo_url'] as String? ?? '',
        role: RoleHelpers.mapRole(userData['role']),
      );

      await localDb.saveUser(creds);
      await local.setRememberMe(false);

      debugPrint('✅ Registro completado');
      debugPrint('🔑 Access Token: ${tokenAccess.substring(0, 20)}...');
      debugPrint('🔄 Refresh Token: ${tokenRefresh.substring(0, 20)}...');

      return Right(creds);
    } catch (e) {
      debugPrint('❌ Error en registerUser: $e');
      return Left(
        UnexpectedFailure(
          message: 'Error al registrar usuario',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthenticationCredentials?>> getSavedSession() async {
    try {
      debugPrint('🔍 Obteniendo sesión guardada de SQLite...');

      final user = await localDb.readUser();

      if (user == null) {
        debugPrint('No hay usuario guardado');
        return const Right(null);
      }

      if (user.tokenAccess.isEmpty) {
        debugPrint('Usuario sin token, limpiando...');
        await localDb.clear();
        return const Right(null);
      }

      debugPrint('Usuario encontrado: ${user.username}');
      return Right(user);
    } catch (e) {
      debugPrint('Error al obtener sesión: $e');
      return Left(
        CacheFailure(
          message: 'Error al obtener sesión guardada',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      debugPrint('🚪 Cerrando sesión...');
      final user = await localDb.readUser();

      await localDb.clear();
      await local.clearSession();
      await _prefs.clear();

      if (_googleInitialized) {
        await _googleSignIn.signOut();
      }
      if (user != null) {
        await authenticationService.closeSessionLogout(
          user.email,
          RoleHelpers.getMnemonicoByRole(user.role),
        );
      }
      debugPrint('Sesión cerrada');
      return const Right(null);
    } catch (e) {
      await localDb.clear();
      await local.clearSession();
      if (_googleInitialized) {
        await _googleSignIn.signOut();
      }
      return const Right(null);
    }
  }
}

class AppException implements Exception {
  final String message;
  final String? details;
  final int? statusCode;
  final DioException? dioException;

  AppException(
    this.message, {
    this.details,
    this.statusCode,
    this.dioException,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AppException: $message');
    if (statusCode != null) buffer.write(' (Status: $statusCode)');
    if (details != null) buffer.write('\nDetails: $details');
    return buffer.toString();
  }
}

class TimeoutException implements Exception {
  final String message;
  final Duration? timeout;

  TimeoutException(this.message, {this.timeout});

  @override
  String toString() {
    final buffer = StringBuffer('TimeoutException: $message');
    if (timeout != null) buffer.write(' (Timeout: ${timeout!.inSeconds}s)');
    return buffer.toString();
  }
}
