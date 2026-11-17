import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DriverPositionSender {
  final String serverUrl;

  DriverPositionSender({required this.serverUrl});

  WebSocketChannel? _channel;
  Timer? _timer;
  StreamSubscription<Position>? _positionSub;

  void start(int driverId) {
    stop();
    final url = '$serverUrl/ws/driver/$driverId/position';
    debugPrint('[DriverPosition] connecting to $url');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        _sendCurrentPosition();
      });

      _sendCurrentPosition();
    } catch (e) {
      debugPrint('[DriverPosition] connection error: $e');
    }
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

      if (pos != null && _channel != null) {
        final data = jsonEncode({
          'latitude': pos.latitude,
          'longitude': pos.longitude,
        });
        _channel!.sink.add(data);
        debugPrint('[DriverPosition] sent: ${pos.latitude}, ${pos.longitude}');
      }
    } catch (e) {
      debugPrint('[DriverPosition] send error: $e');
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _positionSub?.cancel();
    _positionSub = null;
    _channel?.sink.close();
    _channel = null;
    debugPrint('[DriverPosition] stopped');
  }
}
