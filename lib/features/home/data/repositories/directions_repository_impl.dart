import 'package:auronix_app/app/network/error_mapper.dart';
import 'package:auronix_app/core/errors/failure.dart';
import 'package:auronix_app/features/home/data/datasources/directions_remote_data_source.dart';
import 'package:auronix_app/features/home/domain/entities/fare_estimate.dart';
import 'package:auronix_app/features/home/domain/entities/route_info.dart';
import 'package:auronix_app/features/home/domain/repositories/directions_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsRepositoryImpl implements DirectionsRepository {
  DirectionsRepositoryImpl(this._remote);

  final DirectionsRemoteDataSource _remote;

  /// Tarifa preliminar: cargo base + $/km + $/min. Es solo una
  /// previsualizacion para el pasajero antes de solicitar el viaje — el
  /// precio real lo calcula y confirma el backend al crear el viaje.
  static const double _baseFare = 1.00;
  static const double _perKm = 0.35;
  static const double _perMinute = 0.05;
  static const String _currency = 'USD';

  @override
  Future<Either<Failure, RouteInfo>> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final dto = await _remote.getRoute(
        origin: origin,
        destination: destination,
      );
      return Right(dto.toEntity());
    } on RouteNotFoundException catch (e) {
      return Left(RouteNotFoundFailure(detail: e.status));
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'No se pudo calcular la ruta.',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, FareEstimate>> estimateFare({
    required double distanceMeters,
    required int durationSeconds,
  }) async {
    final distanceFare = _round2((distanceMeters / 1000) * _perKm);
    final timeFare = _round2((durationSeconds / 60) * _perMinute);
    final total = _round2(_baseFare + distanceFare + timeFare);

    return Right(
      FareEstimate(
        estimatedPrice: total,
        currency: _currency,
        baseFare: _baseFare,
        distanceFare: distanceFare,
        timeFare: timeFare,
      ),
    );
  }

  static double _round2(double value) => (value * 100).round() / 100;
}
