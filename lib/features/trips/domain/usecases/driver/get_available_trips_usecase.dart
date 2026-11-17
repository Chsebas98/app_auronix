import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';
import 'package:auronix_app/features/trips/domain/repository/trip_repository.dart';
import 'package:dartz/dartz.dart';

class GetAvailableTripsUseCase {
  final TripRepository _repo;
  GetAvailableTripsUseCase(this._repo);

  Future<Either<Failure, List<TripEntity>>> call(int userId) =>
      _repo.getAvailableTrips(userId);
}
