import 'package:auronix_app/app/core/network/types/request_extras.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/features/client/client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthenticationService {
  static String _baseUrl = Environment().config!.apiBaseUrl;

  final Dio _dio;

  AuthenticationService({required Dio dio}) : _dio = dio;

  /// Login/Registro con Google
  Future<Map<String, dynamic>> googleLogin(
    AuthenticationCredentials creds,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/google-login',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {
          'email': creds.email,
          'googleToken': creds.tokenAccess, // token de Google
          'nombre1': creds.firstName,
          'ape1': creds.lastName,
        },
      );
      debugPrint('✅ googleLogin response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;

        return {
          'response': false,
          'statusCode': e.response?.statusCode ?? 0,
          'message': data['message'] ?? 'Error de conexión',
          'errorDetail':
              data['errorDetail'] ?? e.message ?? 'Error desconocido',
        };
      }

      return {
        'response': false,
        'statusCode': e.response?.statusCode ?? 0,
        'message': 'Error de conexión',
        'errorDetail': e.message ?? 'No se pudo conectar al servidor',
      };
    }
  }

  /// ✅ NUEVO: Refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      debugPrint('🔄 Llamando a refresh-token endpoint');

      final response = await _dio.post(
        '$_baseUrl/tb-clients/refresh-token',
        options: Options(
          contentType: 'application/json',
          // NO usar retry aquí para evitar loops
        ),
        data: {'token_refresh': refreshToken},
      );

      debugPrint('✅ refreshToken response: ${response.data}');
      return response.data;
    } catch (e) {
      debugPrint('❌ Error en refreshToken: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {'email': email, 'password': password},
      );

      debugPrint('✅ login response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;

        return {
          'response': false,
          'statusCode': e.response?.statusCode ?? 0,
          'message': data['message'] ?? 'Error de conexión',
          'errorDetail':
              data['errorDetail'] ?? e.message ?? 'Error desconocido',
        };
      }

      return {
        'response': false,
        'statusCode': e.response?.statusCode ?? 0,
        'message': 'Error de conexión',
        'errorDetail': e.message ?? 'No se pudo conectar al servidor',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nombre1,
    required String ape1,
    String? nombre2,
    String? ape2,
    String? username,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/tb-clients/register',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {
          'email': email,
          'password': password,
          'nombre1': nombre1,
          'ape1': ape1,
          if (nombre2 != null) 'nombre2': nombre2,
          if (ape2 != null) 'ape2': ape2,
          if (username != null) 'username': username,
        },
      );
      debugPrint('✅ register response: ${response.data}');
      return response.data;
    } catch (e) {
      debugPrint('❌ Error en register: $e');
      rethrow;
    }
  }
}
