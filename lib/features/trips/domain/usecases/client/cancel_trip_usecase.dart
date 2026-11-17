import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/domain/repository/trip_repository.dart';
import 'package:dartz/dartz.dart';

class CancelTripUseCase {
  final TripRepository _repo;
  CancelTripUseCase(this._repo);

  Future<Either<Failure, void>> call({
    required int userId,
    required int tripId,
    required String motivo,
  }) =>
      _repo.cancelTrip(userId: userId, tripId: tripId, motivo: motivo);
}
