import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/domain/repository/trip_repository.dart';
import 'package:dartz/dartz.dart';

class RejectTripUseCase {
  final TripRepository _repo;
  RejectTripUseCase(this._repo);

  Future<Either<Failure, void>> call({
    required int userId,
    required int tripId,
    String? motivo,
  }) =>
      _repo.rejectTrip(userId: userId, tripId: tripId, motivo: motivo);
}
