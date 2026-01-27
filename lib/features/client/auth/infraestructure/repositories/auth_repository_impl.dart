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
  Future<AuthenticationCredentials> loginOrRegisterWithGoogle(
    AuthenticationCredentials googleCreds,
  ) async {
    try {
      debugPrint('🔐 Iniciando login/registro con Google + Strapi');
      debugPrint('📧 Email: ${googleCreds.email}');

      // 1. Buscar si el usuario existe en Strapi
      final existingUser = await strapiServices.findUserByEmail(
        googleCreds.email,
      );

      StrapiUserResponse strapiUser;

      if (existingUser != null) {
        // 2a. Usuario EXISTE: Actualizar inicio_google y token
        debugPrint('👤 Usuario existente, actualizando...');

        strapiUser = await strapiServices.updateUser(
          documentId: existingUser.documentId,
          inicioGoogle: true,
          tokenAccess: googleCreds.token,
          photoUrl: googleCreds.photoUrl.isNotEmpty
              ? googleCreds.photoUrl
              : null,
        );
      } else {
        // 2b. Usuario NO EXISTE: Crear nuevo
        debugPrint('🆕 Usuario nuevo, creando en Strapi...');

        // Generar username único del email
        final username = googleCreds.email.split('@')[0];

        strapiUser = await strapiServices.createUser(
          email: googleCreds.email,
          username: username,
          nombre1: googleCreds.firstName,
          nombre2: googleCreds.secondName.isNotEmpty
              ? googleCreds.secondName
              : null,
          ape1: googleCreds.lastName.isNotEmpty ? googleCreds.lastName : null,
          ape2: googleCreds.secondlastName.isNotEmpty
              ? googleCreds.secondlastName
              : null,
          photoUrl: googleCreds.photoUrl.isNotEmpty
              ? googleCreds.photoUrl
              : null,
          tokenAccess: googleCreds.token,
          roleId: 2, // ROL_CLIENT - ajusta según tu catálogo
        );
      }

      // 3. Convertir respuesta de Strapi a AuthenticationCredentials
      final authCreds = strapiUser.toAuthCredentials(
        googleToken: googleCreds.token,
      );

      // 4. Guardar en base de datos local
      await localDb.saveUser(authCreds);
      await local.saveToken(authCreds.token);
      await local.setRememberMe(true);

      debugPrint('✅ Login/Registro completado exitosamente');
      debugPrint('👤 Usuario: ${authCreds.firstName} ${authCreds.lastName}');
      debugPrint('🎭 Rol: ${authCreds.role}');
      debugPrint('🔑 Document ID: ${strapiUser.documentId}');

      return authCreds;
    } on StrapiException catch (e) {
      debugPrint('❌ Error de Strapi: $e');
      throw Exception('Error al sincronizar con el servidor: ${e.message}');
    } on TimeoutException catch (e) {
      debugPrint('⏱️ Timeout: $e');
      throw Exception('El servidor no responde. Verifica tu conexión.');
    } catch (e) {
      debugPrint('❌ Error en loginOrRegisterWithGoogle: $e');
      rethrow;
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
