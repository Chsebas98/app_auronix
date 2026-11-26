import 'package:auronix_app/app/network/websocket_manager.dart';

/// Escucha la posición del conductor de un viaje por STOMP
/// (`/topic/trip.{tripId}`, ver `WebSocketManager`).
class ClientPositionListener {
  ClientPositionListener({required WebSocketManager wsManager})
    : _wsManager = wsManager;

  final WebSocketManager _wsManager;
  int? _activeTripId;

  Stream<DriverLocationUpdate> connect(int tripId) {
    if (_activeTripId != null && _activeTripId != tripId) {
      _wsManager.stopWatchingTrip(_activeTripId!);
    }
    _activeTripId = tripId;
    return _wsManager.watchTrip(tripId);
  }

  void disconnect() {
    if (_activeTripId != null) {
      _wsManager.stopWatchingTrip(_activeTripId!);
      _activeTripId = null;
    }
  }
}
