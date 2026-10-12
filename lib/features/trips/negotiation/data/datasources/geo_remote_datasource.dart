import 'package:auronix_app/app/core/network/types/request_extras.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:dio/dio.dart';

/// `GET /geo/autocomplete` / `GET /geo/reverse` (docs/requerimientos_backend.md
/// sección 4.5) — proxy del backend a LocationIQ. A diferencia de los demás
/// endpoints de este proyecto, la respuesta documentada **no** usa el
/// envoltorio `{response, result, message}` — es el arreglo/objeto directo,
/// así que aquí se deja que `DioException` se propague y el repositorio la
/// traduzca a `Failure`.
class GeoRemoteDatasource {
  static String get _baseUrl => Environment().config!.apiBaseUrl;

  final Dio _dio;

  GeoRemoteDatasource({required Dio dio}) : _dio = dio;

  /// Devuelve `List<dynamic>` (cada item `{label, lat, lng}`).
  Future<List<dynamic>> autocomplete({
    required String query,
    double? lat,
    double? lng,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/geo/autocomplete',
      queryParameters: {
        'q': query,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      },
      options: Options(extra: RequestExtras.withRetry(retries: 1)),
    );
    return response.data as List<dynamic>;
  }

  /// Devuelve `{label: "..."}`.
  Future<Map<String, dynamic>> reverse({
    required double lat,
    required double lng,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/geo/reverse',
      queryParameters: {'lat': lat, 'lng': lng},
      options: Options(extra: RequestExtras.withRetry(retries: 1)),
    );
    return response.data as Map<String, dynamic>;
  }
}
