import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/complete_trip_result.dart';
import 'package:auronix_app/features/trips/domain/repository/trip_repository.dart';
import 'package:dartz/dartz.dart';

class CompleteTripUseCase {
  final TripRepository _repo;
  CompleteTripUseCase(this._repo);

  Future<Either<Failure, CompleteTripResult>> call({
    required int userId,
    required int tripId,
    required double distanciaFinalKm,
    required int duracionMinutos,
  }) =>
      _repo.completeTrip(
        userId: userId,
        tripId: tripId,
        distanciaFinalKm: distanciaFinalKm,
        duracionMinutos: duracionMinutos,
      );
}
