import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/db_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// Posición de un conductor recibida por el canal de un viaje (payload
/// `DriverLocationBroadcast` del backend: `driverId`, `latitud`, `longitud`).
class DriverLocationUpdate {
  final int driverId;
  final double latitude;
  final double longitude;

  const DriverLocationUpdate({
    required this.driverId,
    required this.latitude,
    required this.longitude,
  });

  factory DriverLocationUpdate.fromJson(Map<String, dynamic> json) =>
      DriverLocationUpdate(
        driverId: json['driverId'] as int? ?? 0,
        latitude: (json['latitud'] as num).toDouble(),
        longitude: (json['longitud'] as num).toDouble(),
      );
}

/// Gestor genérico de la conexión STOMP del backend (`/ws`, broker
/// `/topic`/`/queue`, auth por JWT en el CONNECT — ver `WebSocketConfig` y
/// `StompAuthChannelInterceptor` de micro-auronix).
///
/// Hoy el backend solo emite por este canal la posición del conductor en
/// `/topic/trip.{tripId}` (`TrackingController`); no hay broadcast de estado
/// de viaje ni de solicitudes nuevas a conductores, así que ese alcance queda
/// fuera de este manager (ver `DriverTripSocket`/`TripStatusSocket`, que
/// siguen en su propio websocket crudo hasta que el backend los soporte).
class WebSocketManager {
  WebSocketManager({
    required String wsBaseUrl,
    AppDatabase? db,
    Duration baseBackoff = const Duration(seconds: 1),
    Duration maxBackoff = const Duration(seconds: 30),
  }) : _endpointUrl = '$wsBaseUrl/ws',
       _db = db ?? AppDatabase.instance,
       _baseBackoff = baseBackoff,
       _maxBackoff = maxBackoff;

  final String _endpointUrl;
  final AppDatabase _db;
  final Duration _baseBackoff;
  final Duration _maxBackoff;

  StompClient? _client;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _wanted = false;

  final Map<int, StreamController<DriverLocationUpdate>> _tripControllers = {};
  final Map<int, StompUnsubscribe> _tripSubscriptions = {};

  bool get isConnected => _client?.connected ?? false;

  /// URL real del endpoint STOMP (ws:// local, wss:// dev/prod — ver
  /// `deriveWsBaseUrl`), expuesta para poder verificarla en tests.
  String get endpointUrl => _endpointUrl;

  /// Abre la conexión STOMP si no existe ya una. Reintenta con backoff
  /// exponencial (1s, 2s, 4s... hasta 30s) ante caídas, mientras [connect]
  /// siga siendo lo último que se pidió (no se haya llamado [disconnect]).
  Future<void> connect() async {
    _wanted = true;
    if (_client != null) return;
    await _activate();
  }

  Future<void> _activate() async {
    final activeUser = await _db.getActiveUserMap();
    final token = activeUser?[DbConstants.colTokenAccess] as String?;

    _client = StompClient(
      config: StompConfig(
        url: _endpointUrl,
        stompConnectHeaders: token != null && token.isNotEmpty
            ? {'Authorization': 'Bearer $token'}
            : null,
        reconnectDelay: Duration.zero, // el backoff lo maneja este manager
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) =>
            debugPrint('[WebSocketManager] error de socket: $error'),
        onStompError: (frame) =>
            debugPrint('[WebSocketManager] error STOMP: ${frame.body}'),
        onWebSocketDone: _scheduleReconnect,
        onDebugMessage: (msg) => debugPrint('[WebSocketManager] $msg'),
      ),
    )..activate();
  }

  void _onConnect(StompFrame frame) {
    _reconnectAttempts = 0;
    debugPrint('[WebSocketManager] conectado a $_endpointUrl');
    // Re-suscribe los canales de viaje que ya estaban activos antes de una
    // reconexión (una nueva sesión STOMP no conserva las suscripciones).
    for (final tripId in _tripControllers.keys) {
      _subscribeTrip(tripId);
    }
  }

  void _scheduleReconnect() {
    if (!_wanted) return;
    final delayMs = min(
      _baseBackoff.inMilliseconds * pow(2, _reconnectAttempts).toInt(),
      _maxBackoff.inMilliseconds,
    );
    _reconnectAttempts++;
    debugPrint(
      '[WebSocketManager] conexión perdida, reintentando en ${delayMs}ms',
    );
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!_wanted) return;
      _client = null;
      _activate();
    });
  }

  /// Stream de posiciones del conductor para un viaje. Idempotente: llamarlo
  /// de nuevo con el mismo [tripId] devuelve el mismo stream ya activo.
  Stream<DriverLocationUpdate> watchTrip(int tripId) {
    final existing = _tripControllers[tripId];
    if (existing != null) return existing.stream;

    final controller = StreamController<DriverLocationUpdate>.broadcast(
      onCancel: () => stopWatchingTrip(tripId),
    );
    _tripControllers[tripId] = controller;

    unawaited(connect());
    if (isConnected) _subscribeTrip(tripId);

    return controller.stream;
  }

  void _subscribeTrip(int tripId) {
    _tripSubscriptions[tripId]?.call();
    _tripSubscriptions[tripId] = _client!.subscribe(
      destination: '/topic/trip.$tripId',
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          _tripControllers[tripId]?.add(DriverLocationUpdate.fromJson(json));
        } catch (e) {
          debugPrint('[WebSocketManager] payload invalido en trip.$tripId: $e');
        }
      },
    );
  }

  void stopWatchingTrip(int tripId) {
    _tripSubscriptions.remove(tripId)?.call();
    _tripControllers.remove(tripId)?.close();
  }

  /// Envía la posición actual del conductor (`/app/driver.location.update`).
  /// El backend resuelve el viaje activo a partir del JWT, no hace falta
  /// indicar tripId ni driverId aquí.
  void sendDriverLocation({
    required double latitude,
    required double longitude,
  }) {
    final client = _client;
    if (client == null || !client.connected) return;
    client.send(
      destination: '/app/driver.location.update',
      body: jsonEncode({'latitud': latitude, 'longitud': longitude}),
    );
  }

  /// Cierra la conexión y cancela cualquier intento de reconexión pendiente.
  void disconnect() {
    _wanted = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    for (final tripId in _tripControllers.keys.toList()) {
      stopWatchingTrip(tripId);
    }
    _client?.deactivate();
    _client = null;
  }
}
