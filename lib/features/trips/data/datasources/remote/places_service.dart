import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Predicción de lugar con coordenadas incluidas (Nominatim devuelve todo en
/// una sola llamada — no se necesita getDetails separado).
class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final double latitude;
  final double longitude;

  const PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    required this.latitude,
    required this.longitude,
  });

  factory PlacePrediction.fromNominatim(Map<String, dynamic> json) {
    final displayName = json['display_name'] as String? ?? '';
    final name = json['name'] as String? ?? '';

    // Separar nombre principal del resto de la dirección
    final parts = displayName.split(',');
    final mainText = name.isNotEmpty ? name : (parts.isNotEmpty ? parts[0].trim() : displayName);
    final secondary = parts.length > 1
        ? parts.sublist(1).map((s) => s.trim()).where((s) => s.isNotEmpty).join(', ')
        : '';

    return PlacePrediction(
      placeId: json['place_id'].toString(),
      description: displayName,
      mainText: mainText,
      secondaryText: secondary,
      latitude: double.tryParse(json['lat'] as String? ?? '0') ?? 0,
      longitude: double.tryParse(json['lon'] as String? ?? '0') ?? 0,
    );
  }
}

/// Detalles de lugar (mantenido para compatibilidad con el template).
class PlaceDetails {
  final double latitude;
  final double longitude;
  final String formattedAddress;

  const PlaceDetails({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });
}

/// Servicio de búsqueda de lugares usando Nominatim (OpenStreetMap).
/// - Gratuito, sin API key, sin billing
/// - Probado: retorna resultados correctos para Ecuador
/// - Rate limit: 1 req/s → usar debounce ≥ 600 ms en el caller
class PlacesService {
  static const _baseUrl = 'https://nominatim.openstreetmap.org';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        // Nominatim requiere User-Agent identificado
        'User-Agent': 'auronix-app/1.0 (contact@auronix.com)',
        'Accept-Language': 'es',
      },
    ),
  );

  PlacesService({String? apiKey});  // apiKey ignorado — usamos Nominatim

  /// Búsqueda de lugares en Ecuador por texto.
  /// Retorna lat/lng directamente en cada predicción.
  Future<List<PlacePrediction>> autocomplete(
    String input, {
    double? lat,
    double? lng,
  }) async {
    if (input.trim().length < 2) return [];
    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'q': input.trim(),
          'countrycodes': 'ec',
          'format': 'json',
          'limit': '8',
          'accept-language': 'es',
          'addressdetails': '0',
          'dedupe': '1',
          // Bias opcional hacia la posición GPS (solo hint, no restringe)
          if (lat != null && lng != null) 'viewbox': '${lng - 1},${lat + 1},${lng + 1},${lat - 1}',
          if (lat != null && lng != null) 'bounded': '0',
        },
      );

      final list = response.data as List<dynamic>;
      debugPrint('[PlacesService] Nominatim: ${list.length} resultados para "$input"');

      return list
          .map((e) => PlacePrediction.fromNominatim(e as Map<String, dynamic>))
          .where((p) => p.latitude != 0 && p.longitude != 0)
          .toList();
    } catch (e) {
      debugPrint('[PlacesService] Nominatim error: $e');
      return [];
    }
  }

  /// Las coordenadas ya vienen en [PlacePrediction] — este método existe solo
  /// por compatibilidad. En Nominatim no se necesita una segunda llamada.
  Future<PlaceDetails?> getDetails(String placeId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/details',
        queryParameters: {
          'place_id': placeId,
          'format': 'json',
          'accept-language': 'es',
        },
      );
      final data = response.data as Map<String, dynamic>;
      final centroid = data['centroid'] as Map<String, dynamic>?;
      final coords = centroid?['coordinates'] as List<dynamic>?;
      if (coords == null || coords.length < 2) return null;
      return PlaceDetails(
        latitude: (coords[1] as num).toDouble(),
        longitude: (coords[0] as num).toDouble(),
        formattedAddress: data['localname'] as String? ?? '',
      );
    } catch (e) {
      debugPrint('[PlacesService] getDetails error: $e');
      return null;
    }
  }
}
