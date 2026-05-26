import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/complete_trip_result.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';
import 'package:dartz/dartz.dart';

abstract class TripRepository {
  // Client
  Future<Either<Failure, TripEntity>> requestTrip({
    required int userId,
    required double origenLatitud,
    required double origenLongitud,
    required String origenDireccion,
    required double destinoLatitud,
    required double destinoLongitud,
    required String destinoDireccion,
    required double distanciaEstimadaKm,
    int? metodoPagoId,
  });

  Future<Either<Failure, TripEntity>> getTripStatus({
    required int userId,
    required String codigoViaje,
  });

  Future<Either<Failure, void>> cancelTrip({
    required int userId,
    required int tripId,
    required String motivo,
  });

  Future<Either<Failure, void>> rateDriver({
    required int userId,
    required int tripId,
    required int calificacion,
    String? comentario,
  });

  // Driver
  Future<Either<Failure, List<TripEntity>>> getAvailableTrips(int userId);

  Future<Either<Failure, TripEntity>> acceptTrip({
    required int userId,
    required int tripId,
  });

  Future<Either<Failure, TripEntity>> startTrip({
    required int userId,
    required int tripId,
  });

  Future<Either<Failure, CompleteTripResult>> completeTrip({
    required int userId,
    required int tripId,
    required double distanciaFinalKm,
    required int duracionMinutos,
  });

  Future<Either<Failure, void>> ratePassenger({
    required int userId,
    required int tripId,
    required int calificacion,
    String? comentario,
  });
}
