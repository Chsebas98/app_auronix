import 'package:auronix_app/app/core/network/types/request_extras.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:dio/dio.dart';

/// Remote datasource para el estado de verificación del conductor
/// (docs/requerimientos_backend.md secciones 2.3 y 4.1).
class VerificationRemoteDatasource {
  static String get _baseUrl => Environment().config!.apiBaseUrl;

  final Dio _dio;

  VerificationRemoteDatasource({required Dio dio}) : _dio = dio;

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

  Future<Map<String, dynamic>> getEstadoVerificacion() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/drivers/me/estado-verificacion',
        options: Options(extra: RequestExtras.withRetry(retries: 2)),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> resendVerificationEmail() async {
    try {
      final response = await _dio.post(
        '$_baseUrl/drivers/me/resend-verification-email',
        options: Options(contentType: 'application/json'),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }
}
