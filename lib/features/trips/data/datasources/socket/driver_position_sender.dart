import 'dart:async';

import 'package:auronix_app/app/network/websocket_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Envía la posición del conductor cada 5s por STOMP
/// (`/app/driver.location.update`, ver `WebSocketManager`).
class DriverPositionSender {
  DriverPositionSender({required WebSocketManager wsManager})
    : _wsManager = wsManager;

  final WebSocketManager _wsManager;
  Timer? _timer;

  void start(int driverId) {
    stop();
    unawaited(_wsManager.connect());
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _sendCurrentPosition();
    });
    _sendCurrentPosition();
  }

  Future<void> _sendCurrentPosition() async {
    try {
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 4),
          ),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos != null) {
        _wsManager.sendDriverLocation(
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
        debugPrint('[DriverPosition] sent: ${pos.latitude}, ${pos.longitude}');
      }
    } catch (e) {
      debugPrint('[DriverPosition] send error: $e');
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
