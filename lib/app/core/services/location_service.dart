import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:auronix_app/core/errors/failure.dart';

class LocationService {
  static const LocationSettings _highAccuracy = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );

  static const LocationSettings _lowAccuracy = LocationSettings(
    accuracy: LocationAccuracy.medium,
    distanceFilter: 50,
  );

  Future<Either<Failure, Position>> getCurrentPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: _highAccuracy,
      );
      return Right(pos);
    } catch (e) {
      return Left(LocationFailure(message: e.toString()));
    }
  }

  Stream<Position> getActiveRideStream() =>
      Geolocator.getPositionStream(locationSettings: _highAccuracy);

  Stream<Position> getIdleDriverStream() =>
      Geolocator.getPositionStream(locationSettings: _lowAccuracy);

  Future<bool> isLocationEnabled() => Geolocator.isLocationServiceEnabled();

  /// Código de país ISO-3166 alpha-2 (ej. `EC`, `PE`, `CO`) a partir de la
  /// ubicación actual del dispositivo — usado para elegir el regex de placa
  /// correcto en el registro de conductor (docs/requerimientos_backend.md
  /// sección 2.1) y, más adelante, la moneda del viaje (docs/flow.md 11.1).
  Future<Either<Failure, String?>> detectCountryCode() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _highAccuracy,
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return const Right(null);
      return Right(placemarks.first.isoCountryCode);
    } catch (e) {
      return Left(LocationFailure(message: e.toString()));
    }
  }

  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();
}
