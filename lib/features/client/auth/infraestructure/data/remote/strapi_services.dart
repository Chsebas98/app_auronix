import 'package:auronix_app/app/core/network/types/request_extras.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/features/client/client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class StrapiServices {
  static String _baseUrl = Environment().config!.apiBaseUrl;

  final Dio _dio;

  StrapiServices({required Dio dio}) : _dio = dio;

  /// Login/Registro con Google
  Future<Map<String, dynamic>> googleLogin(
    AuthenticationCredentials creds,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/tb-clients/google-login',
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
    } catch (e) {
      debugPrint('❌ Error en googleLogin: $e');
      rethrow;
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

  /// ✅ NUEVO: Login con credenciales
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/tb-clients/login',
        options: Options(
          contentType: 'application/json',
          extra: RequestExtras.withRetry(retries: 2),
        ),
        data: {'email': email, 'password': password},
      );
      debugPrint('✅ login response: ${response.data}');
      return response.data;
    } catch (e) {
      debugPrint('❌ Error en login: $e');
      rethrow;
    }
  }

  /// ✅ NUEVO: Registro
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
