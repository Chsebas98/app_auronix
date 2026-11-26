import 'package:auronix_app/features/home/domain/entities/route_info.dart';
import 'package:auronix_app/features/trips/data/datasources/remote/places_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Mapea la respuesta cruda de Google Directions (T18). `status` no es un
/// codigo HTTP: la API responde 200 incluso cuando no hay ruta transitable
/// (`ZERO_RESULTS`/`NOT_FOUND`) — [DirectionsRemoteDataSource] es quien
/// decide, segun [status], si lanzar [RouteNotFoundException].
class DirectionsDto {
  const DirectionsDto({
    required this.status,
    this.points = const [],
    this.distanceMeters = 0,
    this.durationSeconds = 0,
    this.polylineEncoded = '',
  });

  final String status;
  final List<LatLng> points;
  final double distanceMeters;
  final int durationSeconds;
  final String polylineEncoded;

  static const _routeNotFoundStatuses = {'ZERO_RESULTS', 'NOT_FOUND'};

  bool get isRouteNotFound => _routeNotFoundStatuses.contains(status);
  bool get isOk => status == 'OK';

  factory DirectionsDto.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String? ?? 'UNKNOWN_ERROR';
    final routes = json['routes'] as List<dynamic>? ?? [];
    if (routes.isEmpty) return DirectionsDto(status: status);

    final route = routes.first as Map<String, dynamic>;
    final polyline = route['overview_polyline']?['points'] as String? ?? '';
    final legs = route['legs'] as List<dynamic>? ?? [];
    final leg = legs.isNotEmpty ? legs.first as Map<String, dynamic> : null;
    final distanceMeters =
        (leg?['distance']?['value'] as num?)?.toDouble() ?? 0;
    final durationSeconds = (leg?['duration']?['value'] as num?)?.toInt() ?? 0;

    final points = polyline.isEmpty
        ? const <LatLng>[]
        : PlacesService.decodePolyline(
            polyline,
          ).map((pair) => LatLng(pair[0], pair[1])).toList();

    return DirectionsDto(
      status: status,
      points: points,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      polylineEncoded: polyline,
    );
  }

  RouteInfo toEntity() => RouteInfo(
    points: points,
    distanceMeters: distanceMeters,
    durationSeconds: durationSeconds,
    polylineEncoded: polylineEncoded,
  );
}
