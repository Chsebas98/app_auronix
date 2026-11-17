import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';
import 'package:auronix_app/features/trips/domain/repository/trip_repository.dart';
import 'package:dartz/dartz.dart';

class GetTripStatusUseCase {
  final TripRepository _repo;
  GetTripStatusUseCase(this._repo);

  Future<Either<Failure, TripEntity>> call({
    required int userId,
    required String codigoViaje,
  }) =>
      _repo.getTripStatus(userId: userId, codigoViaje: codigoViaje);
}
