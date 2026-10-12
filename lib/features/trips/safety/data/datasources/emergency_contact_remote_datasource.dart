import 'package:auronix_app/app/core/network/types/request_extras.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:dio/dio.dart';

/// `GET/POST/DELETE /users/me/emergency-contacts` (confirmado, ver
/// docs/requerimientos_backend.md sección 4.1). El backend rechaza acciones
/// que dejen al usuario sin ningún contacto — el cliente no necesita
/// replicar esa regla contra la API, solo bloquear la UI mientras la lista
/// esté vacía.
class EmergencyContactRemoteDatasource {
  static String get _baseUrl => Environment().config!.apiBaseUrl;

  final Dio _dio;

  EmergencyContactRemoteDatasource({required Dio dio}) : _dio = dio;

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

  Future<Map<String, dynamic>> getContacts() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/users/me/emergency-contacts',
        options: Options(extra: RequestExtras.withRetry(retries: 2)),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> addContact({
    required String nombre,
    required String telefono,
    required String relacion,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/users/me/emergency-contacts',
        options: Options(contentType: 'application/json'),
        data: {'nombre': nombre, 'telefono': telefono, 'relacion': relacion},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }
}
