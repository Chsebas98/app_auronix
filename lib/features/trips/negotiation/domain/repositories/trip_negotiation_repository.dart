import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/negotiation/domain/models/published_trip_request.dart';
import 'package:auronix_app/features/trips/negotiation/domain/models/trip_estimate.dart';
import 'package:dartz/dartz.dart';

abstract class TripNegotiationRepository {
  /// `POST /trips/estimate` — distancia, duración y precio sugerido para el
  /// par origen/destino actual.
  Future<Either<Failure, TripEstimate>> estimateTrip({
    required double originLat,
    required double originLng,
    required String originAddress,
    required double destinationLat,
    required double destinationLng,
    required String destinationAddress,
  });

  /// `POST /trips/requests` — publica la solicitud con el precio final que
  /// eligió el pasajero (`precioPublicado`, igual o distinto al sugerido).
  /// `solicitudOriginalId` solo aplica al republicar tras expiración (T6.6,
  /// todavía no implementado en la UI).
  Future<Either<Failure, PublishedTripRequest>> publishTripRequest({
    required double originLat,
    required double originLng,
    required String originAddress,
    required double destinationLat,
    required double destinationLng,
    required String destinationAddress,
    required double precioPublicado,
    String? solicitudOriginalId,
  });
}
