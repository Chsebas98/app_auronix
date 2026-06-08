import 'package:auronix_app/app/core/network/types/request_extras.dart';
import 'package:auronix_app/app/environments/environment.dart';
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
          'photo_url': creds.photoUrl,
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
      final response = await _dio.post(
        '$_baseUrl/auth/drivers/login',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {'identificacion': identificacion, 'password': password},
      );
      debugPrint('loginDriver exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> registerDriver(
    Map<String, dynamic> data,
  ) async {
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
