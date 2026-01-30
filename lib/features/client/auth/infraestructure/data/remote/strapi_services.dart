import 'package:auronix_app/app/core/network/extensions/dio_extensions.dart';
import 'package:auronix_app/app/core/network/types/request_extras.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/client/client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class StrapiServices {
  static String _baseUrl = Environment().config!.apiBaseUrl;

  final Dio _dio;

  StrapiServices({required Dio dio}) : _dio = dio;

  /// Buscar usuario por email (CON CACHE + RETRY)
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
          'googleToken': creds.token,
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
}
