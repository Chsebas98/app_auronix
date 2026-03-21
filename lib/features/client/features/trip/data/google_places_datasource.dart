import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/features/client/features/trip/domain/models/interfaces/place_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  Future<Map<String, dynamic>?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      debugPrint('🗺️  [DataSource] Obteniendo ruta...');
      debugPrint('   Origen: ${origin.latitude}, ${origin.longitude}');
      debugPrint(
        '   Destino: ${destination.latitude}, ${destination.longitude}',
      );

      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': apiKey,
          'language': 'es',
          'mode': 'driving',
        },
      );

      debugPrint('📡 [DataSource] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        debugPrint('📄 [DataSource] Response status: ${data['status']}');

        if (data['status'] == 'OK') {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          debugPrint('✅ [DataSource] Ruta obtenida:');
          debugPrint('   Distancia: ${leg['distance']['text']}');
          debugPrint('   Duración: ${leg['duration']['text']}');

          return {
            'polyline': route['overview_polyline']['points'],
            'distance': leg['distance']['value'], // Metros
            'distanceText': leg['distance']['text'], // "5.2 km"
            'duration': leg['duration']['value'], // Segundos
            'durationText': leg['duration']['text'], // "15 min"
            'startAddress': leg['start_address'],
            'endAddress': leg['end_address'],
          };
        } else {
          debugPrint('⚠️ [DataSource] Directions error: ${data['status']}');
          if (data['error_message'] != null) {
            debugPrint(
              '⚠️ [DataSource] Error message: ${data['error_message']}',
            );
          }
          return null;
        }
      } else {
        debugPrint('❌ [DataSource] Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [DataSource] Exception: $e');
      return null;
    }
  }

  // Decodificar polyline
  List<LatLng> decodePolyline(String encoded) {
    try {
      final points = PolylinePoints.decodePolyline(encoded);

      debugPrint('🔓 Polyline decodificada: ${points.length} puntos');

      return points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    } catch (e) {
      debugPrint('❌ Error decodificando polyline: $e');
      return [];
    }
  }
}
