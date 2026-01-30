import 'package:auronix_app/app/database/auth_local_db_datasource.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/client/auth/infraestructure/data/remote/strapi_services.dart';
import 'package:auronix_app/features/features.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteServices remote;
  final AuthLocalServices local;
  final AuthLocalDbDataSource localDb;
  final StrapiServices strapiServices; // NUEVO
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  AuthRepositoryImpl({
    required this.remote,
    required this.local,
    required this.localDb,
    required this.strapiServices, // NUEVO
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
  Future<AuthenticationCredentials> login({
    required String email,
    required String password,
    AuthenticationCredentials isGoogle =
        const AuthenticationCredentials.empty(),
    bool rememberMe = false,
  }) async {
    final response = await remote.loginUser(email: email, password: password);

    await local.saveToken(response['token'] ?? 'hola');
    await local.setRememberMe(true);

    AuthenticationCredentials creds;
    if (isGoogle.username.isEmpty) {
      creds = isGoogle;
    } else {
      creds = AuthenticationCredentials(
        token: response['token'] ?? 'hola',
        firstName: 'Sebas',
        lastName: 'Soberon',
        role: Roles.rolUser,
        secondName: 'Charly',
        secondlastName: 'Mateus',
        username: 'Chsebas',
        email: email,
        photoUrl: '',
      );
    }

    await localDb.saveUser(creds);

    return creds;
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
      token: googleAuth.idToken!,
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

  /// NUEVO: Login o Registro con Google + Sincronización con Strapi
  @override
  Future<ServiceResponse> loginOrRegisterWithGoogle(
    AuthenticationCredentials googleCreds,
  ) async {
    try {
      debugPrint('🔐 Iniciando login/registro con Google + Strapi');
      debugPrint('📧 Email: ${googleCreds.email}');

      // 1. Llamar al endpoint de Google Login en Strapi
      final strapiResponse = await strapiServices.googleLogin(googleCreds);

      debugPrint('📦 Respuesta de Strapi: $strapiResponse');

      // 2. Verificar si la respuesta es exitosa
      if (!strapiResponse['response']) {
        debugPrint('❌ Error desde Strapi: ${strapiResponse['message']}');
        return ServiceResponse.error(
          message: strapiResponse['message'],
          errorDetail: strapiResponse['errorDetail'],
          statusCode: strapiResponse['statusCode'],
        );
      }

      // 3. Extraer datos del resultado
      final result = strapiResponse['result'] as Map<String, dynamic>;
      final jwt = result['jwt'] as String?;
      final userData = result['user'] as Map<String, dynamic>?;
      final isNewUser = result['isNewUser'] as bool? ?? false;

      if (jwt == null || userData == null) {
        debugPrint('JWT o datos de usuario no encontrados en respuesta');
        return ServiceResponse.error(
          message: 'Respuesta inválida del servidor',
          errorDetail: 'JWT o datos de usuario faltantes',
          statusCode: 500,
        );
      }

      debugPrint(
        isNewUser
            ? '🆕 Usuario nuevo registrado: ${userData['email']}'
            : '👤 Usuario existente: ${userData['email']}',
      );
      debugPrint('🔑 JWT recibido: ${jwt.substring(0, 20)}...');
      debugPrint('👤 Username: ${userData['username']}');
      debugPrint('🎭 Rol: ${userData['role']?['nombre_catalogo']}');

      // 4. Guardar en base de datos local (descomentar cuando esté listo)
      // await localDb.saveUser(userData);
      // await local.saveToken(jwt);
      // await local.setRememberMe(true);

      debugPrint('✅ Login/Registro completado exitosamente');

      // 5. Retornar respuesta exitosa
      return ServiceResponse.success(
        message: isNewUser
            ? 'Usuario registrado exitosamente'
            : 'Inicio de sesión exitoso',
        result: {'jwt': jwt, 'user': userData, 'isNewUser': isNewUser},
        statusCode: strapiResponse['statusCode'],
      );
    } on DioException catch (e) {
      debugPrint('❌ Error DioException: ${e.message}');
      debugPrint('📍 Type: ${e.type}');
      debugPrint('�� Response: ${e.response?.data}');

      // Intentar parsear error del backend
      if (e.response?.data != null && e.response!.data is Map) {
        final errorData = e.response!.data as Map<String, dynamic>;
        return ServiceResponse.error(
          message:
              errorData['message'] ?? 'Error de comunicación con el servidor',
          errorDetail:
              errorData['errorDetail'] ?? e.message ?? 'Error desconocido',
          statusCode: e.response?.statusCode ?? 500,
        );
      }

      return ServiceResponse.error(
        message: 'Error de comunicación con el servidor',
        errorDetail: e.message ?? 'Sin conexión',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado en loginOrRegisterWithGoogle: $e');
      debugPrint('📍 StackTrace: $stackTrace');

      return ServiceResponse.error(
        message: 'Error inesperado al procesar login',
        errorDetail: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> logout() async {
    localDb.clear();
    await local.clearSession();

    // Cerrar sesión de Google si está iniciada
    if (_googleInitialized) {
      await _googleSignIn.signOut();
    }
  }

  Future<bool> hasSavedUser() async {
    final user = await localDb.readUser();
    return user != null;
  }

  @override
  Future<AuthenticationCredentials?> getSavedSession() {
    return localDb.readUser();
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
