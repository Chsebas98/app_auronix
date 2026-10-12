import 'package:auronix_app/app/environments/environment.dart';
import 'package:dio/dio.dart';

/// `POST /trips/estimate` / `POST /trips/requests` (docs/
/// requerimientos_backend.md sección 4.1, docs/flow.md sección 3).
class TripNegotiationRemoteDatasource {
  static String get _baseUrl => Environment().config!.apiBaseUrl;

  final Dio _dio;

  TripNegotiationRemoteDatasource({required Dio dio}) : _dio = dio;

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

  Map<String, dynamic> _origenDestino({
    required double originLat,
    required double originLng,
    required String originAddress,
    required double destinationLat,
    required double destinationLng,
    required String destinationAddress,
  }) => {
    'origen': {
      'lat': originLat,
      'lng': originLng,
      'direccion': originAddress,
    },
    'destino': {
      'lat': destinationLat,
      'lng': destinationLng,
      'direccion': destinationAddress,
    },
  };

  Future<Map<String, dynamic>> estimateTrip({
    required double originLat,
    required double originLng,
    required String originAddress,
    required double destinationLat,
    required double destinationLng,
    required String destinationAddress,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/trips/estimate',
        options: Options(contentType: 'application/json'),
        data: _origenDestino(
          originLat: originLat,
          originLng: originLng,
          originAddress: originAddress,
          destinationLat: destinationLat,
          destinationLng: destinationLng,
          destinationAddress: destinationAddress,
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> publishTripRequest({
    required double originLat,
    required double originLng,
    required String originAddress,
    required double destinationLat,
    required double destinationLng,
    required String destinationAddress,
    required double precioPublicado,
    String? solicitudOriginalId,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/trips/requests',
        options: Options(contentType: 'application/json'),
        data: {
          ..._origenDestino(
            originLat: originLat,
            originLng: originLng,
            originAddress: originAddress,
            destinationLat: destinationLat,
            destinationLng: destinationLng,
            destinationAddress: destinationAddress,
          ),
          'precioPublicado': precioPublicado,
          if (solicitudOriginalId != null)
            'solicitudOriginalId': solicitudOriginalId,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }
}
