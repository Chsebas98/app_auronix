import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DriverPositionUpdate {
  final double latitude;
  final double longitude;
  final int driverId;

  const DriverPositionUpdate({
    required this.latitude,
    required this.longitude,
    required this.driverId,
  });

  factory DriverPositionUpdate.fromJson(Map<String, dynamic> json) {
    return DriverPositionUpdate(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      driverId: json['driver_id'] as int? ?? 0,
    );
  }
}

class ClientPositionListener {
  final String serverUrl;

  ClientPositionListener({required this.serverUrl});

  WebSocketChannel? _channel;
  final _controller = StreamController<DriverPositionUpdate>.broadcast();

  Stream<DriverPositionUpdate> connect(int tripId) {
    disconnect();
    final url = '$serverUrl/ws/trip/$tripId/position';
    debugPrint('[ClientPosition] connecting to $url');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel!.stream.listen(
        (raw) {
          try {
            final envelope = jsonDecode(raw as String) as Map<String, dynamic>;
            final event = envelope['event'] as String?;

            if (event == 'driver.position.updated') {
              final data = envelope['data'] as Map<String, dynamic>;
              final update = DriverPositionUpdate.fromJson(data);
              _controller.add(update);
              debugPrint(
                  '[ClientPosition] driver at ${update.latitude}, ${update.longitude}');
            }
          } catch (e) {
            debugPrint('[ClientPosition] parse error: $e');
          }
        },
        onError: (e) {
          debugPrint('[ClientPosition] stream error: $e');
          Future.delayed(const Duration(seconds: 3), () {
            if (!_controller.isClosed) connect(tripId);
          });
        },
        onDone: () {
          debugPrint('[ClientPosition] stream closed');
        },
      );
    } catch (e) {
      debugPrint('[ClientPosition] connection error: $e');
    }

    return _controller.stream;
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    debugPrint('[ClientPosition] disconnected');
  }
}
