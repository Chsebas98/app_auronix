import 'dart:async';
import 'dart:convert';

import 'package:auronix_app/features/trips/data/models/trip_response_model.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_socket_events.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TripStatusSocket {
  final String _serverUrl;
  WebSocketChannel? _channel;
  StreamController<TripStatusEvent>? _controller;
  bool _disposed = false;

  TripStatusSocket({required String serverUrl}) : _serverUrl = serverUrl;

  Stream<TripStatusEvent> connect(int tripId) {
    _disposed = false;
    _controller = StreamController<TripStatusEvent>.broadcast();

    _openChannel(tripId);
    return _controller!.stream;
  }

  void _openChannel(int tripId) {
    if (_disposed) return;

    _channel = WebSocketChannel.connect(
      Uri.parse('$_serverUrl/ws/trip/$tripId/status'),
    );

    _channel!.stream.listen(
      _onMessage,
      onError: (_) => _reconnect(tripId),
      onDone: () => _reconnect(tripId),
      cancelOnError: false,
    );
  }

  void _onMessage(dynamic raw) {
    try {
      final envelope = jsonDecode(raw as String) as Map<String, dynamic>;
      if (envelope['event'] == 'trip.status.updated') {
        final payload = envelope['data'] as Map<String, dynamic>;
        final tripId = payload['trip_id'] as int;
        final status = payload['status'] as String;
        final data = payload['data'] as Map<String, dynamic>?;
        final trip = data != null ? TripResponseModel.fromJson(data).toEntity() : null;

        _controller?.add(TripStatusEvent(
          tripId: tripId,
          status: status,
          trip: trip,
        ));
      }
    } catch (_) {}
  }

  void _reconnect(int tripId) {
    if (_disposed) return;
    Future.delayed(const Duration(seconds: 3), () => _openChannel(tripId));
  }

  void disconnect() {
    _disposed = true;
    _channel?.sink.close();
    _controller?.close();
    _channel = null;
    _controller = null;
  }
}
