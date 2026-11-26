// Prueba WebSocketManager (T7) contra un broker STOMP real y minimo servido
// por dart:io (HttpServer + WebSocketTransformer), no un fake del cliente:
// se habla el protocolo de verdad (frames STOMP con terminador NUL) sobre un
// WebSocket real en localhost, igual que lo haria micro-auronix.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/db_constants.dart';
import 'package:auronix_app/app/network/websocket_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AppDatabase db;
  late _FakeStompBroker broker;

  setUp(() async {
    db = AppDatabase.instance;
    final conn = await db.database;
    await conn.delete(DbConstants.tableUser);
    await db.upsertUserMap({
      DbConstants.colTokenAccess: 'token-abc',
      DbConstants.colRole: 'rolUser',
      DbConstants.colFirstName: 'Test',
      DbConstants.colLastName: 'User',
    }, DbConstants.userTypeClient);

    broker = _FakeStompBroker();
    await broker.start();
  });

  tearDown(() async {
    await broker.close();
  });

  test(
    'T7-C1 T7-C3 T7-C6: conecta al endpoint STOMP con esquema ws:// local y manda el JWT en el CONNECT',
    () async {
      final manager = WebSocketManager(
        wsBaseUrl: 'ws://127.0.0.1:${broker.port}',
      );
      addTearDown(manager.disconnect);

      expect(manager.endpointUrl, 'ws://127.0.0.1:${broker.port}/ws');

      await manager.connect();
      final connectFrame = await broker.firstConnect;
      // broker.firstConnect se resuelve en cuanto el SERVIDOR recibe el
      // CONNECT; el CLIENTE todavia necesita procesar la vuelta CONNECTED
      // antes de marcarse conectado, asi que se espera eso por separado
      // (bajo carga esa vuelta no es instantanea).
      await _waitUntil(() => manager.isConnected);

      expect(connectFrame.headers['Authorization'], 'Bearer token-abc');
      expect(manager.isConnected, isTrue);
    },
  );

  test(
    'T7-C5: los eventos de posicion del topic de un viaje llegan como DriverLocationUpdate tipado',
    () async {
      final manager = WebSocketManager(
        wsBaseUrl: 'ws://127.0.0.1:${broker.port}',
      );
      addTearDown(manager.disconnect);

      final events = <DriverLocationUpdate>[];
      final sub = manager.watchTrip(42).listen(events.add);
      addTearDown(sub.cancel);

      await broker.firstConnect;
      await broker.firstSubscribe;
      broker.sendTripMessage(42, {
        'driverId': 7,
        'latitud': -0.180653,
        'longitud': -78.467838,
      });

      await Future.doWhile(() async {
        if (events.isNotEmpty) return false;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return true;
      }).timeout(const Duration(seconds: 5));

      expect(events, hasLength(1));
      expect(events.single.driverId, 7);
      expect(events.single.latitude, closeTo(-0.180653, 0.0000001));
      expect(events.single.longitude, closeTo(-78.467838, 0.0000001));
    },
  );

  test(
    'T7-C2 T7-C4 T7-C7: ante una caida de conexion, reconecta sola con backoff exponencial creciente',
    () async {
      final manager = WebSocketManager(
        wsBaseUrl: 'ws://127.0.0.1:${broker.port}',
        baseBackoff: const Duration(milliseconds: 100),
        maxBackoff: const Duration(seconds: 2),
      );
      addTearDown(manager.disconnect);

      // El broker rechaza (cierra sin CONNECTED) los primeros 2 intentos y
      // recien acepta el 3ro — asi se mide el backoff entre fallos
      // consecutivos de verdad, sin que un exito de por medio reinicie el
      // contador (el manager si reinicia el backoff tras cada reconexion
      // exitosa, que es el comportamiento correcto).
      broker.refuseFirstConnects(2);

      await manager.connect();

      final firstFailedConnect = await broker
          .connectAt(0)
          .timeout(const Duration(seconds: 5));
      final secondFailedConnect = await broker
          .connectAt(1)
          .timeout(const Duration(seconds: 5));
      final thirdConnect = await broker
          .connectAt(2)
          .timeout(const Duration(seconds: 5));

      final firstGapMs = secondFailedConnect.receivedAt
          .difference(firstFailedConnect.receivedAt)
          .inMilliseconds;
      final secondGapMs = thirdConnect.receivedAt
          .difference(secondFailedConnect.receivedAt)
          .inMilliseconds;

      // El segundo intento de reconexion debe tardar mas que el primero
      // (backoff exponencial, no un retry a intervalo fijo).
      expect(secondGapMs, greaterThan(firstGapMs));
      await _waitUntil(() => manager.isConnected);
      expect(manager.isConnected, isTrue);
    },
  );
}

/// Espera a que [condition] sea verdadera, sin asumir que un evento del
/// servidor implica que el cliente ya termino de procesar su respuesta.
Future<void> _waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('_waitUntil: condicion no se cumplio a tiempo');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class _StompConnectFrame {
  _StompConnectFrame(this.headers, this.receivedAt);
  final Map<String, String> headers;
  final DateTime receivedAt;
}

/// Broker STOMP de juguete: entiende CONNECT/SUBSCRIBE/SEND lo suficiente
/// para estas pruebas, y puede simular una caida de conexion a demanda.
class _FakeStompBroker {
  HttpServer? _server;
  WebSocket? _socket;
  String? _lastSubscriptionId;
  int _refuseNextConnects = 0;

  final List<_StompConnectFrame> connects = [];

  /// Los proximos [count] CONNECT que reciba se cierran sin responder
  /// CONNECTED (simula fallos de red consecutivos para probar backoff real).
  void refuseFirstConnects(int count) => _refuseNextConnects = count;
  final List<Completer<void>> _subscribeWaiters = [];
  bool _subscribedOnce = false;

  int get port => _server!.port;

  Future<_StompConnectFrame> get firstConnect => connectAt(0);

  Future<_StompConnectFrame> connectAt(int index) async {
    while (connects.length <= index) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    return connects[index];
  }

  Future<void> get firstSubscribe async {
    if (_subscribedOnce) return;
    final completer = Completer<void>();
    _subscribeWaiters.add(completer);
    return completer.future;
  }

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((request) async {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        final socket = await WebSocketTransformer.upgrade(request);
        _socket = socket;
        socket.listen(
          (dynamic message) => _onFrame(socket, message as String),
          onDone: () {},
        );
      } else {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
      }
    });
  }

  void _onFrame(WebSocket socket, String raw) {
    final withoutNull = raw.endsWith('\u0000')
        ? raw.substring(0, raw.length - 1)
        : raw;
    final lines = withoutNull.split('\n');
    if (lines.isEmpty || lines.first.isEmpty) return;
    final command = lines.first;

    final headers = <String, String>{};
    var i = 1;
    for (; i < lines.length; i++) {
      if (lines[i].isEmpty) break;
      final sepIndex = lines[i].indexOf(':');
      if (sepIndex == -1) continue;
      headers[lines[i].substring(0, sepIndex)] = lines[i].substring(
        sepIndex + 1,
      );
    }

    switch (command) {
      case 'CONNECT':
      case 'STOMP':
        connects.add(_StompConnectFrame(headers, DateTime.now()));
        if (_refuseNextConnects > 0) {
          _refuseNextConnects--;
          socket.close();
        } else {
          socket.add('CONNECTED\nversion:1.2\n\n\u0000');
        }
      case 'SUBSCRIBE':
        _lastSubscriptionId = headers['id'];
        _subscribedOnce = true;
        for (final waiter in _subscribeWaiters) {
          if (!waiter.isCompleted) waiter.complete();
        }
        _subscribeWaiters.clear();
      default:
        break;
    }
  }

  void sendTripMessage(int tripId, Map<String, dynamic> payload) {
    final body = jsonEncode(payload);
    final frame =
        'MESSAGE\n'
        'subscription:${_lastSubscriptionId ?? '0'}\n'
        'message-id:1\n'
        'destination:/topic/trip.$tripId\n'
        'content-type:application/json\n'
        '\n'
        '$body\u0000';
    _socket?.add(frame);
  }

  void dropCurrentConnection() {
    _socket?.close();
    _socket = null;
  }

  Future<void> close() async {
    await _socket?.close();
    await _server?.close(force: true);
  }
}
