import 'dart:async';
import 'dart:convert';

import 'package:auronix_app/features/trips/domain/models/interfaces/trip_socket_events.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DriverTripSocket {
  final String _serverUrl;
  WebSocketChannel? _channel;
  StreamController<TripRequestEvent>? _controller;
  bool _disposed = false;

  DriverTripSocket({required String serverUrl}) : _serverUrl = serverUrl;

  Stream<TripRequestEvent> connect(int driverId) {
    _disposed = false;
    _controller = StreamController<TripRequestEvent>.broadcast();

    _openChannel(driverId);
    return _controller!.stream;
  }

  void _openChannel(int driverId) {
    if (_disposed) return;

    _channel = WebSocketChannel.connect(
      Uri.parse('$_serverUrl/ws/driver/$driverId/requests'),
    );

    _channel!.stream.listen(
      _onMessage,
      onError: (_) => _reconnect(driverId),
      onDone: () => _reconnect(driverId),
      cancelOnError: false,
    );
  }

  void _onMessage(dynamic raw) {
    try {
      final envelope = jsonDecode(raw as String) as Map<String, dynamic>;
      if (envelope['event'] == 'trip.request.new') {
        final data = envelope['data'] as Map<String, dynamic>;
        _controller?.add(TripRequestEvent.fromJson(data));
      }
    } catch (_) {}
  }

  void _reconnect(int driverId) {
    if (_disposed) return;
    Future.delayed(const Duration(seconds: 3), () => _openChannel(driverId));
  }

  void disconnect() {
    _disposed = true;
    _channel?.sink.close();
    _controller?.close();
    _channel = null;
    _controller = null;
  }
}
