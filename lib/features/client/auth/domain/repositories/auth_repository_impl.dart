import 'package:auronix_app/app/database/auth_local_db_datasource.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/features.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalServices local;
  final AuthLocalDbDataSource localDb;
  final AuthenticationService authenticationService; // NUEVO
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final RxSharedPreferences _prefs = sl<RxSharedPreferences>();
  bool _googleInitialized = false;

  AuthRepositoryImpl({
    required this.local,
    required this.localDb,
    required this.authenticationService, // NUEVO
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
  Future<ServiceResponse> login({
    required String email,
    required String password,
    AuthenticationCredentials isGoogle =
        const AuthenticationCredentials.empty(),
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
        return ServiceResponse.error(
          message: response['message'],
          errorDetail: response['errorDetail'],
          statusCode: response['statusCode'],
        );
      }

      final result = response['result'] as Map<String, dynamic>;

      // 🔑 EXTRAER AMBOS TOKENS
      final tokenAccess = result['token_access'] as String?;
      final tokenRefresh = result['token_refresh'] as String?;
      final userData = result['user'] as Map<String, dynamic>?;

      if (tokenAccess == null || tokenRefresh == null || userData == null) {
        return ServiceResponse.error(
          message: 'Respuesta inválida del servidor',
          errorDetail: 'Tokens o datos de usuario faltantes',
          statusCode: 500,
        );
      }

      // ✅ CREAR CREDENTIALS CON DATOS DEL BACKEND
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

      // ✅ GUARDAR EN BD LOCAL
      await localDb.saveUser(creds);
      await local.setRememberMe(rememberMe);

      debugPrint('✅ Login completado');
      debugPrint('🔑 Access Token: ${tokenAccess.substring(0, 20)}...');
      debugPrint('🔄 Refresh Token: ${tokenRefresh.substring(0, 20)}...');

      return ServiceResponse.success(
        message: 'Inicio de sesión exitoso',
        result: {
          'token_access': tokenAccess,
          'token_refresh': tokenRefresh,
          'user': userData,
        },
        statusCode: response['statusCode'],
      );
    } catch (e, _) {
      debugPrint('❌ Error en login: $e');
      return ServiceResponse.error(
        message: 'Error inesperado',
        errorDetail: e.toString(),
        statusCode: 500,
      );
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  @override
  Future<AuthenticationCredentials> loginWithGoogle() async {
    await _ensureGoogleInitialized();

    final googleAccount = await _googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleAccount.authentication;
    debugPrintStack(label: 'Google Auth: ${googleAuth.idToken}');
    if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
      throw GoogleSignInException(
        code: GoogleSignInExceptionCode.unknownError,
        description: 'El token no se obtuvo correctamente',
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

    return authModel;
  }

  @override
  Future<ServiceResponse> loginOrRegisterWithGoogle(
    AuthenticationCredentials googleCreds,
  ) async {
    try {
      debugPrint('🔐 Iniciando login/registro con Google + Strapi');
      debugPrint('📧 Email: ${googleCreds.email}');

      final response = await authenticationService.googleLogin(googleCreds);

      if (!response['response']) {
        return ServiceResponse.error(
          message: response['message'],
          errorDetail: response['errorDetail'],
          statusCode: response['statusCode'],
        );
      }

      final result = response['result'] as Map<String, dynamic>;

      // �� EXTRAER AMBOS TOKENS
      final tokenAccess = result['token_access'] as String?;
      final tokenRefresh = result['token_refresh'] as String?;
      final userData = result['user'] as Map<String, dynamic>?;
      final isNewUser = result['isNewUser'] as bool? ?? false;

      if (tokenAccess == null || tokenRefresh == null || userData == null) {
        return ServiceResponse.error(
          message: 'Respuesta inválida del servidor',
          errorDetail: 'Tokens o datos de usuario faltantes',
          statusCode: 500,
        );
      }

      // ✅ CREAR CREDENTIALS CON AMBOS TOKENS
      final creds = googleCreds.copyWith(
        tokenAccess: tokenAccess,
        tokenRefresh: tokenRefresh,
        username: userData['username'] as String,
        // ... otros campos del userData
      );

      // ✅ GUARDAR EN BD LOCAL
      await localDb.saveUser(creds);
      await local.setRememberMe(true);

      debugPrint('✅ Login/Registro completado');
      debugPrint('🔑 Access Token: ${tokenAccess.substring(0, 20)}...');
      debugPrint('🔄 Refresh Token: ${tokenRefresh.substring(0, 20)}...');

      return ServiceResponse.success(
        message: isNewUser
            ? 'Usuario registrado exitosamente'
            : 'Inicio de sesión exitoso',
        result: {
          'token_access': tokenAccess,
          'token_refresh': tokenRefresh,
          'user': userData,
          'isNewUser': isNewUser,
        },
        statusCode: response['statusCode'],
      );
    } catch (e, _) {
      debugPrint('❌ Error en loginOrRegisterWithGoogle: $e');
      return ServiceResponse.error(
        message: 'Error inesperado',
        errorDetail: e.toString(),
        statusCode: 500,
      );
    }
  }

  Future<bool> hasSavedUser() async {
    final user = await localDb.readUser();
    return user != null;
  }

  @override
  Future<ServiceResponse> verifyRegister(
    RegisterVerifyRequest registerData,
  ) async {
    try {
      final response = await authenticationService.verifyRegister(
        registerData: registerData,
      );

      if (!response['response']) {
        return ServiceResponse.error(
          message: response['message'],
          errorDetail: response['errorDetail'],
          statusCode: response['statusCode'],
        );
      }

      return ServiceResponse.success(
        message: response['message'] ?? 'Verificación exitosa',
        statusCode: response['statusCode'],
      );
    } catch (e) {
      debugPrint('❌ Error en verifyRegister: $e');
      throw StrapiException(
        'Error al verificar usuario',
        details: e.toString(),
      );
    }
  }

  @override
  Future<ServiceResponse> registerUser(RegisterRequest registerData) async {
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
        return ServiceResponse.error(
          message: response['message'],
          errorDetail: response['errorDetail'],
          statusCode: response['statusCode'],
        );
      }

      final result = response['result'] as Map<String, dynamic>;

      // 🔑 EXTRAER AMBOS TOKENS
      final tokenAccess = result['token_access'] as String?;
      final tokenRefresh = result['token_refresh'] as String?;
      final userData = result['user'] as Map<String, dynamic>?;

      if (tokenAccess == null || tokenRefresh == null || userData == null) {
        return ServiceResponse.error(
          message: 'Respuesta inválida del servidor',
          errorDetail: 'Tokens o datos de usuario faltantes',
          statusCode: 500,
        );
      }

      // ✅ CREAR CREDENTIALS CON DATOS DEL BACKEND
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

      // ✅ GUARDAR EN BD LOCAL
      await localDb.saveUser(creds);
      await local.setRememberMe(false);

      debugPrint('✅ Login completado');
      debugPrint('🔑 Access Token: ${tokenAccess.substring(0, 20)}...');
      debugPrint('🔄 Refresh Token: ${tokenRefresh.substring(0, 20)}...');

      return ServiceResponse.success(
        message: 'Inicio de sesión exitoso',
        result: {
          'token_access': tokenAccess,
          'token_refresh': tokenRefresh,
          'user': userData,
        },
        statusCode: response['statusCode'],
      );
    } catch (e) {
      debugPrint('❌ Error en registerUser: $e');
      throw StrapiException(
        'Error al registrar usuario',
        details: e.toString(),
      );
    }
  }

  @override
  Future<AuthenticationCredentials?> getSavedSession() async {
    try {
      debugPrint('🔍 Obteniendo sesión guardada de SQLite...');

      final user = await localDb.readUser();

      if (user == null) {
        debugPrint('No hay usuario guardado');
        return null;
      }

      // Verificar que tenga token
      if (user.tokenAccess.isEmpty) {
        debugPrint('Usuario sin token, limpiando...');
        await localDb.clear();
        return null;
      }

      debugPrint('Usuario encontrado: ${user.username}');
      return user;
    } catch (e) {
      debugPrint('Error al obtener sesión: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      debugPrint('🚪 Cerrando sesión...');
      final user = await localDb.readUser();
      // 1. Limpiar SQLite
      await localDb.clear();

      // 2. Limpiar SharedPreferences
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
    } catch (e) {
      await localDb.clear();
      await local.clearSession();
      if (_googleInitialized) {
        await _googleSignIn.signOut();
      }
    }

    // Cerrar sesión de Google si está iniciada
  }
}

class StrapiException implements Exception {
  final String message;
  final String? details;
  final int? statusCode;
  final DioException? dioException;

  StrapiException(
    this.message, {
    this.details,
    this.statusCode,
    this.dioException,
  });

  @override
  String toString() {
    final buffer = StringBuffer('StrapiException: $message');
    if (statusCode != null) buffer.write(' (Status: $statusCode)');
    if (details != null) buffer.write('\nDetails: $details');
    return buffer.toString();
  }
}

/// Excepción para timeouts
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
