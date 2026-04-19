import 'package:auronix_app/app/database/auth_local_db_datasource.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/client/client.dart';
import 'package:auronix_app/features/conductor/auth/data/remote/conductor_auth_service.dart';
import 'package:auronix_app/features/conductor/auth/domain/repository/auth_conductor_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class AuthConductorRepositoryImpl implements AuthConductorRepository {
  final ConductorAuthService _conductorAuthService;
  final AuthLocalDbDataSource _localDb;
  final RxSharedPreferences _prefs;

  AuthConductorRepositoryImpl({
    required ConductorAuthService conductorAuthService,
    required AuthLocalDbDataSource localDb,
    required RxSharedPreferences prefs,
  })  : _conductorAuthService = conductorAuthService,
        _localDb = localDb,
        _prefs = prefs;

  @override
  Future<void> setRemember(bool value) async {
    await _prefs.setBool(StaticVariables.rememberConductorKey, value);
  }

  @override
  Future<bool> getRemember() async {
    return await _prefs.getBool(StaticVariables.rememberConductorKey) ?? false;
  }

  @override
  Future<Either<Failure, AuthenticationCredentials>> login({
    required String ciPassport,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      debugPrint('🔐 Iniciando login de conductor');

      final response = await _conductorAuthService.loginConductor(
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
        email: userData['email'] as String? ?? '',
        username: userData['username'] as String? ?? ciPassport,
        firstName: userData['nombre1'] as String? ?? '',
        lastName: userData['ape1'] as String? ?? '',
        secondName: userData['nombre2'] as String? ?? '',
        secondlastName: userData['ape2'] as String? ?? '',
        photoUrl: userData['photo_url'] as String? ?? '',
        role: RoleHelpers.mapRole(userData['role']),
      );

      await _localDb.saveUser(creds);
      await setRemember(rememberMe);

      debugPrint('✅ Login de conductor completado');

      return Right(creds);
    } catch (e) {
      debugPrint('❌ Error en login de conductor: $e');
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al iniciar sesión',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthenticationCredentials>> register({
    required String ciPassport,
    required String password,
    required String email,
  }) async {
    try {
      debugPrint('📝 Iniciando registro de conductor');

      final response = await _conductorAuthService.registerConductor(
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
        email: userData['email'] as String? ?? email,
        username: userData['username'] as String? ?? ciPassport,
        firstName: userData['nombre1'] as String? ?? '',
        lastName: userData['ape1'] as String? ?? '',
        secondName: userData['nombre2'] as String? ?? '',
        secondlastName: userData['ape2'] as String? ?? '',
        photoUrl: userData['photo_url'] as String? ?? '',
        role: RoleHelpers.mapRole(userData['role']),
      );

      await _localDb.saveUser(creds);

      debugPrint('✅ Registro de conductor completado');
      return Right(creds);
    } catch (e) {
      debugPrint('❌ Error en registro de conductor: $e');
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al registrar conductor',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      debugPrint('🚪 Cerrando sesión de conductor...');
      await _localDb.clear();
      await _prefs.remove(StaticVariables.rememberConductorKey);
      debugPrint('Sesión de conductor cerrada');
      return const Right(null);
    } catch (e) {
      debugPrint('⚠️ Error al cerrar sesión de conductor: $e');
      await _localDb.clear();
      return const Right(null);
    }
  }
}
