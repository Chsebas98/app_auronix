import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Ruta geometrica entre dos puntos (T18): polilinea decodificada, distancia
/// y duracion estimadas segun el proveedor de direcciones.
class RouteInfo {
  const RouteInfo({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.polylineEncoded,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final int durationSeconds;
  final String polylineEncoded;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteInfo &&
          other.distanceMeters == distanceMeters &&
          other.durationSeconds == durationSeconds &&
          other.polylineEncoded == polylineEncoded &&
          other.points.length == points.length);

  @override
  int get hashCode => Object.hash(
    distanceMeters,
    durationSeconds,
    polylineEncoded,
    points.length,
  );
}
