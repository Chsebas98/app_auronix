import 'package:auronix_app/features/home/data/models/directions_dto.dart';
import 'package:auronix_app/features/trips/data/datasources/remote/places_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Ruta no transitable segun Google Directions (`status` ZERO_RESULTS/
/// NOT_FOUND) — no es un error de transporte (HTTP), por eso no es un
/// DioException: DirectionsRepositoryImpl la mapea a RouteNotFoundFailure.
class RouteNotFoundException implements Exception {
  const RouteNotFoundException(this.status);
  final String status;

  @override
  String toString() => 'RouteNotFoundException($status)';
}

/// Adapta el PlacesService existente (T18: no crear un datasource paralelo,
/// mismo criterio que T17) a traves de fetchDirectionsRaw, que a diferencia
/// de getRoutePoints() no captura errores.
class DirectionsRemoteDataSource {
  DirectionsRemoteDataSource(this._service);

  final PlacesService _service;

  Future<DirectionsDto> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final raw = await _service.fetchDirectionsRaw(
      originLat: origin.latitude,
      originLng: origin.longitude,
      destLat: destination.latitude,
      destLng: destination.longitude,
    );
    final dto = DirectionsDto.fromJson(raw);
    if (dto.isRouteNotFound) {
      throw RouteNotFoundException(dto.status);
    }
    if (!dto.isOk) {
      throw FormatException('Directions respondio status=${dto.status}');
    }
    return dto;
  }
}
