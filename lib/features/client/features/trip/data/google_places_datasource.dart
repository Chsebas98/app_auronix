import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/features/client/features/trip/domain/models/interfaces/place_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';

class GooglePlacesDatasource {
  // static String _baseUrl = Environment().config!.apiBaseUrl;
  static String apiKey = Environment().config!.googleMapsApiKey;

  final Dio _dio;

  GooglePlacesDatasource({required Dio dio}) : _dio = dio;

  Future<List<PlaceModel>> searchPlaces(String query) async {
    try {
      debugPrint('🔍 Buscando lugares: $query');

      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': apiKey,
          'language': 'es',
          'components': 'country:ec',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;

          // Obtener detalles de cada lugar (para coordenadas)
          final places = await Future.wait(
            predictions.take(5).map((prediction) async {
              final placeId = prediction['place_id'];
              return await getPlaceDetails(placeId, prediction['description']);
            }),
          );

          return places.whereType<PlaceModel>().toList();
        } else {
          debugPrint('⚠️ Google Places error: ${data['status']}');
          return [];
        }
      } else {
        debugPrint('❌ Error en búsqueda: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error buscando lugares: $e');
      return [];
    }
  }

  /// Obtiene detalles de un lugar específico (coordenadas)
  Future<PlaceModel?> getPlaceDetails(
    String placeId,
    String description,
  ) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': apiKey,
          'fields': 'geometry,name,formatted_address',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == 'OK') {
          final result = data['result'];
          final location = result['geometry']['location'];

          return PlaceModel(
            placeId: placeId,
            name: result['name'] ?? description,
            address: result['formatted_address'] ?? description,
            lat: location['lat'],
            lng: location['lng'],
          );
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error obteniendo detalles: $e');
      return null;
    }
  }
}
