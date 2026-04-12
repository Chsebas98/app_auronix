import 'package:auronix_app/app/core/network/types/request_extras.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ConductorAuthService {
  static String get _baseUrl => Environment().config!.apiBaseUrl;

  final Dio _dio;

  ConductorAuthService({required Dio dio}) : _dio = dio;

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

  Future<Map<String, dynamic>> loginConductor({
    required String ciPassport,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/drivers/login',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {'ci_passport': ciPassport, 'password': password},
      );
      debugPrint('✅ loginConductor exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> registerConductor({
    required String ciPassport,
    required String password,
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/drivers/register',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {
          'ci_passport': ciPassport,
          'password': password,
          'email': email,
        },
      );
      debugPrint('✅ registerConductor exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      debugPrint('🔄 Llamando a refresh-token (conductor)');
      final response = await _dio.post(
        '$_baseUrl/auth/drivers/refresh-token',
        options: Options(contentType: 'application/json'),
        data: {'token_refresh': refreshToken},
      );
      debugPrint('✅ refreshToken (conductor) exitoso');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }
}
