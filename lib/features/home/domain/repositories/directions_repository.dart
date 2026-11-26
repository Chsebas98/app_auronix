import 'package:auronix_app/core/errors/failure.dart';
import 'package:auronix_app/features/home/domain/entities/fare_estimate.dart';
import 'package:auronix_app/features/home/domain/entities/route_info.dart';
import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class DirectionsRepository {
  Future<Either<Failure, RouteInfo>> getRoute({
    required LatLng origin,
    required LatLng destination,
  });

  Future<Either<Failure, FareEstimate>> estimateFare({
    required double distanceMeters,
    required int durationSeconds,
  });
}
