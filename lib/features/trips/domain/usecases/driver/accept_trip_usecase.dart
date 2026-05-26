import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';
import 'package:auronix_app/features/trips/domain/repository/trip_repository.dart';
import 'package:dartz/dartz.dart';

class AcceptTripUseCase {
  final TripRepository _repo;
  AcceptTripUseCase(this._repo);

  Future<Either<Failure, TripEntity>> call({
    required int userId,
    required int tripId,
  }) =>
      _repo.acceptTrip(userId: userId, tripId: tripId);
}
