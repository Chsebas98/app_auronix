import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auronix_app/features/trips/data/datasources/socket/trip_status_socket.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_socket_events.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late Completer<WebSocket> firstConnection;
  late Completer<WebSocket> secondConnection;
  late int connectionCount;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    firstConnection = Completer<WebSocket>();
    secondConnection = Completer<WebSocket>();
    connectionCount = 0;

    server.listen((request) async {
      if (request.uri.path != '/ws/trip/1/status') {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      final webSocket = await WebSocketTransformer.upgrade(request);
      connectionCount++;
      if (connectionCount == 1) {
        firstConnection.complete(webSocket);
      } else if (connectionCount == 2) {
        secondConnection.complete(webSocket);
      }
    });
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('emits decoded trip status messages from the WebSocket server', () async {
    final socket = TripStatusSocket(
      serverUrl: 'ws://${server.address.address}:${server.port}',
    );
    addTearDown(socket.disconnect);
    final eventReceived = Completer<TripStatusEvent>();
    final subscription = socket.connect(1).listen(eventReceived.complete);
    final webSocket = await firstConnection.future.timeout(
      const Duration(seconds: 5),
    );

    webSocket.add(jsonEncode({
      'event': 'trip.status.updated',
      'data': {'trip_id': 1, 'status': 'ACEPTADO', 'data': null},
    }));

    final event = await eventReceived.future.timeout(
      const Duration(seconds: 5),
    );
    expect(event.tripId, 1);
    expect(event.status, 'ACEPTADO');
    expect(event.trip, isNull);

    await subscription.cancel();
    socket.disconnect();
  });

  test('T25-C2 reconnects after a dropped connection on the same stream',
      () async {
    final socket = TripStatusSocket(
      serverUrl: 'ws://${server.address.address}:${server.port}',
    );
    addTearDown(socket.disconnect);
    final firstEvent = Completer<TripStatusEvent>();
    final reconnectedEvent = Completer<TripStatusEvent>();
    var receivedCount = 0;
    final stream = socket.connect(1);
    final subscription = stream.listen((event) {
      receivedCount++;
      if (receivedCount == 1) {
        firstEvent.complete(event);
      } else {
        reconnectedEvent.complete(event);
      }
    });
    final firstWebSocket = await firstConnection.future.timeout(
      const Duration(seconds: 5),
    );

    firstWebSocket.add(jsonEncode({
      'event': 'trip.status.updated',
      'data': {'trip_id': 1, 'status': 'ACEPTADO', 'data': null},
    }));
    expect((await firstEvent.future).status, 'ACEPTADO');

    await firstWebSocket.close();
    final secondWebSocket = await secondConnection.future.timeout(
      const Duration(seconds: 8),
    );
    expect(connectionCount, 2);

    secondWebSocket.add(jsonEncode({
      'event': 'trip.status.updated',
      'data': {'trip_id': 1, 'status': 'EN_CURSO', 'data': null},
    }));

    final eventAfterReconnect = await reconnectedEvent.future.timeout(
      const Duration(seconds: 5),
    );
    expect(eventAfterReconnect.tripId, 1);
    expect(eventAfterReconnect.status, 'EN_CURSO');

    await subscription.cancel();
    socket.disconnect();
  });
}
