import 'package:auronix_app/app/core/network/types/request_extras.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/app/network/error_mapper.dart';
import 'package:auronix_app/core/errors/failure.dart';
import 'package:auronix_app/features/auth/data/models/auth_response_model.dart';
import 'package:auronix_app/features/auth/data/models/login_request_model.dart';
import 'package:auronix_app/features/auth/data/models/register_request_model.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Unified remote datasource for all authentication operations
/// (client and driver).
class AuthRemoteDatasource {
  static String get _baseUrl => Environment().config!.apiBaseUrl;

  final Dio _dio;

  AuthRemoteDatasource({required Dio dio}) : _dio = dio;

  Map<String, dynamic> _handleDioException(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      return {
        'response': false,
        'statusCode': e.response?.statusCode ?? 0,
        'message': data['message'] ?? 'Error de conexión',
        'errorDetail': data['errorDetail'] ?? e.message ?? 'Error desconocido',
      };
    }
    return {
      'response': false,
      'statusCode': e.response?.statusCode ?? 0,
      'message': 'Error de conexión',
      'errorDetail': e.message ?? 'No se pudo conectar al servidor',
    };
  }

  // ──────────── Backend real (/api/v1/auth/{login,register}) ────────────
  // T11: a diferencia de los metodos de abajo (que llaman rutas por rol que
  // no existen en el backend real, ver docs/architecture/existing_foundation.md),
  // estos dos hablan el contrato real tal como lo expone AuthController.
  // Los errores se mapean con ErrorMapper (T8) y se relanzan como
  // AuthRequestException en vez de devolver un Map silencioso: quien llama
  // puede distinguir un 401 de credenciales invalidas de un 404 por falta
  // de endpoint (relevante para loginOrRegisterWithGoogle, T11).

  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: request.toJson(),
      );
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AuthRequestException(ErrorMapper.fromDioException(e));
    }
  }

  Future<Map<String, dynamic>> register(RegisterRequestModel request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/register',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: request.toJson(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AuthRequestException(ErrorMapper.fromDioException(e));
    }
  }

  // ──────────────────── CLIENT ────────────────────

  Future<Map<String, dynamic>> loginClient({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/clients/login',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {'email': email, 'password': password},
      );
      debugPrint('loginClient exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> googleLogin(
    AuthenticationCredentials creds,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/clients/google-login',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {
          'email': creds.email,
          'googleId': creds.username,
          'googleToken': creds.tokenAccess,
          'nombre1': creds.firstName,
          'ape1': creds.lastName,
          'photoUrl': creds.photoUrl,
        },
      );
      debugPrint('googleLogin exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> verifyRegisterClient({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/clients/verify-register',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {'email': email, 'password': password},
      );
      debugPrint('verifyRegisterClient exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> registerClient(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/clients/register',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: data,
      );
      debugPrint('registerClient exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> refreshClientToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/clients/refresh-token',
        options: Options(contentType: 'application/json'),
        data: {'refreshToken': refreshToken},
      );
      debugPrint('refreshClientToken exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> closeSessionLogout(
    String email,
    String mnemonic,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/clients/logout',
        options: Options(contentType: 'application/json'),
        data: {'email': email},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  // ──────────────────── DRIVER ────────────────────

  Future<Map<String, dynamic>> loginDriver({
    required String identificacion,
    required String password,
  }) async {
    try {
      final data = {'identificacion': identificacion, 'password': password};
      debugPrint('[loginDriver] data enviada: $data');

      final response = await _dio.post(
        '$_baseUrl/auth/drivers/login',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: data,
      );
      debugPrint('[loginDriver] response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('[loginDriver] error response: ${e.response?.data}');
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> registerDriver(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/drivers/register',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: data,
      );
      debugPrint('registerDriver exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> refreshDriverToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/drivers/refresh-token',
        options: Options(contentType: 'application/json'),
        data: {'refreshToken': refreshToken},
      );
      debugPrint('refreshDriverToken exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }
}

/// Lleva un [Failure] ya tipado (ver [ErrorMapper]) desde el datasource hasta
/// el repositorio, para distinguir p.ej. un 401 de credenciales invalidas de
/// un 404 por falta de endpoint sin depender de inspeccionar el status code
/// en dos capas distintas.
class AuthRequestException implements Exception {
  final Failure failure;

  const AuthRequestException(this.failure);

  @override
  String toString() => 'AuthRequestException: ${failure.message}';
}
