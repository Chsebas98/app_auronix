import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/data/datasources/remote/client_trip_remote_datasource.dart';
import 'package:auronix_app/features/trips/data/datasources/remote/driver_trip_remote_datasource.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/complete_trip_result.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';
import 'package:auronix_app/features/trips/domain/repository/trip_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class TripRepositoryImpl implements TripRepository {
  final ClientTripRemoteDatasource _clientRemote;
  final DriverTripRemoteDatasource _driverRemote;

  TripRepositoryImpl({
    required ClientTripRemoteDatasource clientRemote,
    required DriverTripRemoteDatasource driverRemote,
  })  : _clientRemote = clientRemote,
        _driverRemote = driverRemote;

  // ──────────────────── Helpers ────────────────────

  Either<Failure, T> _handleError<T>(Object e) {
    if (e is DioException && e.response?.data != null) {
      final body = e.response!.data as Map<String, dynamic>;
      return Left(ServerFailure(
        message: body['message'] as String? ?? 'Error del servidor',
        statusCode: e.response?.statusCode,
      ));
    }
    return Left(UnexpectedFailure(message: e.toString()));
  }

  // ──────────────────── Client ────────────────────

  @override
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
  }) async {
    try {
      final model = await _clientRemote.requestTrip(
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
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, TripEntity>> getTripStatus({
    required int userId,
    required String codigoViaje,
  }) async {
    try {
      final model = await _clientRemote.getTripStatus(
        userId: userId,
        codigoViaje: codigoViaje,
      );
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, void>> cancelTrip({
    required int userId,
    required int tripId,
    required String motivo,
  }) async {
    try {
      await _clientRemote.cancelTrip(
          userId: userId, tripId: tripId, motivo: motivo);
      return const Right(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, void>> rateDriver({
    required int userId,
    required int tripId,
    required int calificacion,
    String? comentario,
  }) async {
    try {
      await _clientRemote.rateDriver(
        userId: userId,
        tripId: tripId,
        calificacion: calificacion,
        comentario: comentario,
      );
      return const Right(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ──────────────────── Driver ────────────────────

  @override
  Future<Either<Failure, List<TripEntity>>> getAvailableTrips(
      int userId) async {
    try {
      final models = await _driverRemote.getAvailableTrips(userId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, TripEntity>> acceptTrip({
    required int userId,
    required int tripId,
  }) async {
    try {
      final model =
          await _driverRemote.acceptTrip(userId: userId, tripId: tripId);
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, TripEntity>> startTrip({
    required int userId,
    required int tripId,
  }) async {
    try {
      final model =
          await _driverRemote.startTrip(userId: userId, tripId: tripId);
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, CompleteTripResult>> completeTrip({
    required int userId,
    required int tripId,
    required double distanciaFinalKm,
    required int duracionMinutos,
  }) async {
    try {
      final model = await _driverRemote.completeTrip(
        userId: userId,
        tripId: tripId,
        distanciaFinalKm: distanciaFinalKm,
        duracionMinutos: duracionMinutos,
      );
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, void>> ratePassenger({
    required int userId,
    required int tripId,
    required int calificacion,
    String? comentario,
  }) async {
    try {
      await _driverRemote.ratePassenger(
        userId: userId,
        tripId: tripId,
        calificacion: calificacion,
        comentario: comentario,
      );
      return const Right(null);
    } catch (e) {
      return _handleError(e);
    }
  }
}
