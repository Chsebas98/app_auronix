import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/features/trips/data/models/trip_response_model.dart';
import 'package:dio/dio.dart';

class ClientTripRemoteDatasource {
  static String get _baseUrl => Environment().config!.apiBaseUrl;

  final Dio _dio;

  ClientTripRemoteDatasource({required Dio dio}) : _dio = dio;

  Options _headers(int userId) => Options(
        contentType: 'application/json',
        headers: {'X-User-Id': userId},
      );

  Future<TripResponseModel> requestTrip({
    required int userId,
    required double origenLatitud,
    required double origenLongitud,
    required String origenDireccion,
    required double destinoLatitud,
    required double destinoLongitud,
    required String destinoDireccion,
    required double distanciaEstimadaKm,
    int? metodoPagoId,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/trips/request',
      options: _headers(userId),
      data: {
        'origen_latitud': origenLatitud,
        'origen_longitud': origenLongitud,
        'origen_direccion': origenDireccion,
        'destino_latitud': destinoLatitud,
        'destino_longitud': destinoLongitud,
        'destino_direccion': destinoDireccion,
        'distancia_estimada_km': distanciaEstimadaKm,
        'metodo_pago_id': metodoPagoId,
      },
    );
    final body = response.data as Map<String, dynamic>;
    return TripResponseModel.fromJson(body['result'] as Map<String, dynamic>);
  }

  Future<TripResponseModel> getTripStatus({
    required int userId,
    required String codigoViaje,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/trips/get-status',
      options: _headers(userId),
      data: {'codigoViaje': codigoViaje},
    );
    final body = response.data as Map<String, dynamic>;
    return TripResponseModel.fromJson(body['result'] as Map<String, dynamic>);
  }

  Future<void> cancelTrip({
    required int userId,
    required int tripId,
    required String motivo,
  }) async {
    await _dio.post(
      '$_baseUrl/trips/cancel',
      options: _headers(userId),
      data: {'tripId': tripId, 'motivo': motivo},
    );
  }

  Future<void> rateDriver({
    required int userId,
    required int tripId,
    required int calificacion,
    String? comentario,
  }) async {
    await _dio.post(
      '$_baseUrl/trips/rate-driver',
      options: _headers(userId),
      data: {
        'tripId': tripId,
        'calificacion': calificacion,
        'comentario': comentario,
      },
    );
  }
}
