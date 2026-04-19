import 'package:auronix_app/core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class TripRepository {
  /// Busca lugares usando Google Places
  Future<Either<Failure, List<Map<String, dynamic>>>> searchPlaces(
    String query,
  );

  /// Obtiene detalles de un lugar específico
  Future<Either<Failure, Map<String, dynamic>>> getPlaceDetails(String placeId);

  Future<Either<Failure, Map<String, dynamic>>> getDirections({
    required LatLng origin,
    required LatLng destination,
  });
}
