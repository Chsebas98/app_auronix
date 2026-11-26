import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Bounding box que encuadra origen, destino y todos los puntos de la ruta
/// (T21-C8). Funcion pura y separada del widget porque GoogleMap es una
/// vista de plataforma nativa — no hay onMapCreated real en flutter_test
/// sin el paquete integration_test, asi que el calculo de limites se prueba
/// aqui directamente, sin necesitar renderizar el mapa.
LatLngBounds computeRouteBounds({
  required LatLng origin,
  required LatLng destination,
  List<LatLng> routePoints = const [],
}) {
  final points = [origin, destination, ...routePoints];
  var minLat = points.first.latitude;
  var maxLat = points.first.latitude;
  var minLng = points.first.longitude;
  var maxLng = points.first.longitude;
  for (final point in points) {
    minLat = point.latitude < minLat ? point.latitude : minLat;
    maxLat = point.latitude > maxLat ? point.latitude : maxLat;
    minLng = point.longitude < minLng ? point.longitude : minLng;
    maxLng = point.longitude > maxLng ? point.longitude : maxLng;
  }
  return LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
}

/// Mapa de previsualizacion de ruta (T21): dibuja los marcadores de origen
/// (verde) y destino (rojo), traza la polilinea y ajusta automaticamente la
/// camara al bounding box de la ruta completa.
class RouteMapPreview extends StatefulWidget {
  const RouteMapPreview({
    required this.origin,
    required this.destination,
    this.routePoints = const [],
    this.cameraPadding = 64,
    super.key,
  });

  final LatLng origin;
  final LatLng destination;
  final List<LatLng> routePoints;
  final double cameraPadding;

  @override
  State<RouteMapPreview> createState() => _RouteMapPreviewState();
}

class _RouteMapPreviewState extends State<RouteMapPreview> {
  final Completer<GoogleMapController> _controllerCompleter = Completer();

  @override
  void didUpdateWidget(covariant RouteMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.origin != widget.origin ||
        oldWidget.destination != widget.destination ||
        oldWidget.routePoints != widget.routePoints) {
      _fitBounds();
    }
  }

  Future<void> _fitBounds() async {
    final controller = await _controllerCompleter.future;
    final bounds = computeRouteBounds(
      origin: widget.origin,
      destination: widget.destination,
      routePoints: widget.routePoints,
    );
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, widget.cameraPadding),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: widget.origin, zoom: 14),
      onMapCreated: (controller) {
        if (!_controllerCompleter.isCompleted) {
          _controllerCompleter.complete(controller);
        }
        _fitBounds();
      },
      markers: {
        Marker(
          markerId: const MarkerId('route_preview_origin'),
          position: widget.origin,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
        Marker(
          markerId: const MarkerId('route_preview_destination'),
          position: widget.destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      },
      polylines: widget.routePoints.length >= 2
          ? {
              Polyline(
                polylineId: const PolylineId('route_preview_polyline'),
                points: widget.routePoints,
                width: 4,
              ),
            }
          : {},
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
    );
  }
}
