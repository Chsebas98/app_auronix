import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/client/features/trip/data/google_places_datasource.dart';
import 'package:auronix_app/features/client/features/trip/domain/repository/trip_repository.dart';
import 'package:flutter/material.dart';

class TripRepositoryImpl implements TripRepository {
  final GooglePlacesDatasource _placesDataSource;

  TripRepositoryImpl({required GooglePlacesDatasource placesDataSource})
    : _placesDataSource = placesDataSource;

  @override
  Future<ServiceResponse> searchPlaces(String query) async {
    try {
      debugPrint('🔍 [Repository] Buscando lugares: $query');

      final places = await _placesDataSource.searchPlaces(query);

      if (places.isEmpty) {
        return ServiceResponse.success(
          message: 'No se encontraron resultados',
          result: [],
          statusCode: 200,
        );
      }

      debugPrint('✅ [Repository] ${places.length} lugares encontrados');

      return ServiceResponse.success(
        message: 'Lugares encontrados',
        result: places.map((p) => p.toJson()).toList(),
        statusCode: 200,
      );
    } catch (e) {
      debugPrint('❌ [Repository] Error buscando lugares: $e');
      return ServiceResponse.error(
        message: 'Error al buscar lugares',
        errorDetail: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ServiceResponse> getPlaceDetails(String placeId) async {
    try {
      debugPrint('📍 [Repository] Obteniendo detalles del lugar: $placeId');

      final place = await _placesDataSource.getPlaceDetails(placeId, '');

      if (place == null) {
        return ServiceResponse.error(
          message: 'No se pudo obtener los detalles del lugar',
          statusCode: 404,
        );
      }

      debugPrint('✅ [Repository] Detalles obtenidos: ${place.name}');

      return ServiceResponse.success(
        message: 'Detalles del lugar obtenidos',
        result: place.toJson(),
        statusCode: 200,
      );
    } catch (e) {
      debugPrint('❌ [Repository] Error obteniendo detalles: $e');
      return ServiceResponse.error(
        message: 'Error al obtener detalles del lugar',
        errorDetail: e.toString(),
        statusCode: 500,
      );
    }
  }
}
