import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/domain/repository/trip_repository.dart';
import 'package:dartz/dartz.dart';

class RatePassengerUseCase {
  final TripRepository _repo;
  RatePassengerUseCase(this._repo);

  Future<Either<Failure, void>> call({
    required int userId,
    required int tripId,
    required int calificacion,
    String? comentario,
  }) =>
      _repo.ratePassenger(
        userId: userId,
        tripId: tripId,
        calificacion: calificacion,
        comentario: comentario,
      );
}
