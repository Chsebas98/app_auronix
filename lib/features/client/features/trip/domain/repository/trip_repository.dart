import 'package:auronix_app/core/core.dart';

abstract class TripRepository {
  /// Busca lugares usando Google Places
  Future<ServiceResponse> searchPlaces(String query);

  /// Obtiene detalles de un lugar específico
  Future<ServiceResponse> getPlaceDetails(String placeId);

  // TODO: Agregar después
  // Future<ServiceResponse> requestTrip({required TripRequest request});
  // Future<ServiceResponse> getTripDetails(String tripId);
  // Future<ServiceResponse> cancelTrip(String tripId);
}
