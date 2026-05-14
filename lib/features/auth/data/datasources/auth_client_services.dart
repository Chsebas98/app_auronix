import 'package:auronix_app/app/core/network/types/request_extras.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_request.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_verify_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthClientServices {
  static String _baseUrl = Environment().config!.apiBaseUrl;

  final Dio _dio;

  AuthClientServices({required Dio dio}) : _dio = dio;

  /// Login/Registro con Google
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
        '$_baseUrl/auth/clients/refresh-token',
        options: Options(
          contentType: 'application/json',
          // NO usar retry aquí para evitar loops
        ),
        data: {'token_refresh': refreshToken},
      );

      debugPrint('✅ refreshToken response: ${response.data}');
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

  Future<Map<String, dynamic>> loginUser({
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

  Future<Map<String, dynamic>> verifyRegister({
    required RegisterVerifyRequest registerData,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/clients/verify-register',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: registerData.toJson(),
      );
      debugPrint('✅ register response: ${response.data}');
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

  Future<Map<String, dynamic>> register({
    required RegisterRequest registerData,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/clients/register',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: registerData.toJson(),
      );
      debugPrint('✅ register response: ${response.data}');
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

  Future<Map<String, dynamic>> closeSessionLogout(
    String email,
    String roleMnemonico,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/logout',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {'email': email, 'role': roleMnemonico},
      );
      debugPrint('logout response: ${response.data}');
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
}
