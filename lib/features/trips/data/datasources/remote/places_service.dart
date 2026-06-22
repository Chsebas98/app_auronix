import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final double latitude;
  final double longitude;
  final double distanceKm;

  const PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    required this.latitude,
    required this.longitude,
    this.distanceKm = 0,
  });

  PlacePrediction copyWith({double? distanceKm}) => PlacePrediction(
        placeId: placeId,
        description: description,
        mainText: mainText,
        secondaryText: secondaryText,
        latitude: latitude,
        longitude: longitude,
        distanceKm: distanceKm ?? this.distanceKm,
      );

  factory PlacePrediction.fromGooglePlaces(Map<String, dynamic> json) {
    final mainText =
        (json['structured_formatting']?['main_text'] as String?) ?? '';
    final secondaryText =
        (json['structured_formatting']?['secondary_text'] as String?) ?? '';

    return PlacePrediction(
      placeId: json['place_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mainText: mainText,
      secondaryText: secondaryText,
      latitude: 0,
      longitude: 0,
    );
  }
}

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

class PlacesService {
  static const _baseUrl = 'https://maps.googleapis.com/maps/api';

  final String _apiKey;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  PlacesService({required String apiKey}) : _apiKey = apiKey;

  Future<List<PlacePrediction>> autocomplete(
    String input, {
    double? lat,
    double? lng,
  }) async {
    if (input.trim().length < 2) return [];
    try {
      final params = <String, dynamic>{
        'input': input.trim(),
        'key': _apiKey,
        'components': 'country:ec',
        'language': 'es',
        if (lat != null && lng != null) 'location': '$lat,$lng',
        if (lat != null && lng != null) 'radius': '50000',
      };

      final response = await _dio.get(
        '$_baseUrl/place/autocomplete/json',
        queryParameters: params,
      );

      final predictions =
          (response.data['predictions'] as List<dynamic>?) ?? [];
      debugPrint(
          '[PlacesService] Google Places: ${predictions.length} resultados para "$input"');

      final results = <PlacePrediction>[];
      for (final p in predictions) {
        final pred =
            PlacePrediction.fromGooglePlaces(p as Map<String, dynamic>);
        if (pred.placeId.isEmpty) continue;

        final details = await getDetails(pred.placeId);
        if (details == null) continue;

        var enriched = PlacePrediction(
          placeId: pred.placeId,
          description: pred.description.isNotEmpty
              ? pred.description
              : details.formattedAddress,
          mainText: pred.mainText,
          secondaryText: pred.secondaryText.isNotEmpty
              ? pred.secondaryText
              : details.formattedAddress,
          latitude: details.latitude,
          longitude: details.longitude,
        );

        if (lat != null && lng != null) {
          final d =
              _haversineKm(lat, lng, details.latitude, details.longitude);
          enriched = enriched.copyWith(distanceKm: d);
        }
        results.add(enriched);
      }

      if (lat != null && lng != null) {
        results.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      }

      return results.take(8).toList();
    } catch (e) {
      debugPrint('[PlacesService] Google Places error: $e');
      return [];
    }
  }

  Future<PlaceDetails?> getDetails(String placeId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': _apiKey,
          'fields': 'geometry,formatted_address,name',
          'language': 'es',
        },
      );

      final result = response.data['result'] as Map<String, dynamic>?;
      if (result == null) return null;

      final location =
          result['geometry']?['location'] as Map<String, dynamic>?;
      if (location == null) return null;

      return PlaceDetails(
        latitude: (location['lat'] as num).toDouble(),
        longitude: (location['lng'] as num).toDouble(),
        formattedAddress: result['formatted_address'] as String? ??
            result['name'] as String? ??
            '',
      );
    } catch (e) {
      debugPrint('[PlacesService] getDetails error: $e');
      return null;
    }
  }

  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/geocode/json',
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': _apiKey,
          'language': 'es',
          'result_type': 'street_address|route|premise',
        },
      );

      final results =
          (response.data['results'] as List<dynamic>?) ?? [];
      if (results.isEmpty) return null;

      return results.first['formatted_address'] as String?;
    } catch (e) {
      debugPrint('[PlacesService] reverseGeocode error: $e');
      return null;
    }
  }

  static double _haversineKm(
    double lat1, double lng1, double lat2, double lng2,
  ) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _toRad(double deg) => deg * (math.pi / 180);
}
