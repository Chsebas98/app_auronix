import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/features/trips/data/models/complete_trip_result_model.dart';
import 'package:auronix_app/features/trips/data/models/trip_response_model.dart';
import 'package:dio/dio.dart';

class DriverTripRemoteDatasource {
  static String get _baseUrl => Environment().config!.apiBaseUrl;

  final Dio _dio;

  DriverTripRemoteDatasource({required Dio dio}) : _dio = dio;

  Options _headers(int userId) => Options(
        contentType: 'application/json',
        headers: {'X-User-Id': userId},
      );

  Future<List<TripResponseModel>> getAvailableTrips(int userId) async {
    final response = await _dio.post(
      '$_baseUrl/trips/get-available',
      options: _headers(userId),
      data: {},
    );
    final body = response.data as Map<String, dynamic>;
    final list = body['result'] as List<dynamic>? ?? [];
    return list
        .map((e) => TripResponseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TripResponseModel> acceptTrip({
    required int userId,
    required int tripId,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/trips/accept',
      options: _headers(userId),
      data: {'tripId': tripId},
    );
    final body = response.data as Map<String, dynamic>;
    return TripResponseModel.fromJson(body['result'] as Map<String, dynamic>);
  }

  Future<TripResponseModel> startTrip({
    required int userId,
    required int tripId,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/trips/start',
      options: _headers(userId),
      data: {'tripId': tripId},
    );
    final body = response.data as Map<String, dynamic>;
    return TripResponseModel.fromJson(body['result'] as Map<String, dynamic>);
  }

  Future<CompleteTripResultModel> completeTrip({
    required int userId,
    required int tripId,
    required double distanciaFinalKm,
    required int duracionMinutos,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/trips/complete',
      options: _headers(userId),
      data: {
        'tripId': tripId,
        'distanciaFinalKm': distanciaFinalKm,
        'duracionMinutos': duracionMinutos,
      },
    );
    final body = response.data as Map<String, dynamic>;
    return CompleteTripResultModel.fromJson(
        body['result'] as Map<String, dynamic>);
  }

  Future<void> ratePassenger({
    required int userId,
    required int tripId,
    required int calificacion,
    String? comentario,
  }) async {
    await _dio.post(
      '$_baseUrl/trips/rate-passenger',
      options: _headers(userId),
      data: {
        'tripId': tripId,
        'calificacion': calificacion,
        'comentario': comentario,
      },
    );
  }
}
