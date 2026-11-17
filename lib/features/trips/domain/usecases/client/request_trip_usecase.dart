import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';
import 'package:auronix_app/features/trips/domain/repository/trip_repository.dart';
import 'package:dartz/dartz.dart';

class RequestTripUseCase {
  final TripRepository _repo;
  RequestTripUseCase(this._repo);

  Future<Either<Failure, TripEntity>> call({
    required int userId,
    required double origenLatitud,
    required double origenLongitud,
    required String origenDireccion,
    required double destinoLatitud,
    required double destinoLongitud,
    required String destinoDireccion,
    required double distanciaEstimadaKm,
    int? metodoPagoId,
  }) =>
      _repo.requestTrip(
        userId: userId,
        origenLatitud: origenLatitud,
        origenLongitud: origenLongitud,
        origenDireccion: origenDireccion,
        destinoLatitud: destinoLatitud,
        destinoLongitud: destinoLongitud,
        destinoDireccion: destinoDireccion,
        distanciaEstimadaKm: distanciaEstimadaKm,
        metodoPagoId: metodoPagoId,
      );
}
