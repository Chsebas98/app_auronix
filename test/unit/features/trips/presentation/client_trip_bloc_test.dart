// Prueba ClientTripBloc (T24, el PassengerTripBloc que pide la Tarea 0 —
// ya existia desde T6 con este nombre). Mismo patron que
// location_search_bloc_test.dart (T19 de Ando): fakes con contador de
// llamadas, sin mockito ni bloc_test, escuchando bloc.stream antes de
// despachar eventos.

import 'dart:async';

import 'package:auronix_app/app/network/websocket_manager.dart';
import 'package:auronix_app/core/errors/failure.dart';
import 'package:auronix_app/features/trips/data/datasources/socket/client_position_listener.dart';
import 'package:auronix_app/features/trips/data/datasources/socket/trip_status_socket.dart';
import 'package:auronix_app/features/trips/domain/exceptions/active_trip_exception.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/complete_trip_result.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_socket_events.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_status.dart';
import 'package:auronix_app/features/trips/domain/repository/trip_repository.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/cancel_trip_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/rate_driver_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/request_trip_usecase.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTripRepository implements TripRepository {
  int requestTripCalls = 0;
  Either<Failure, TripEntity> Function()? requestTripResult;
  Object? requestTripError;

  @override
  Future<Either<Failure, TripEntity>> requestTrip({
    required int userId,
    required double origenLatitud,
    required double origenLongitud,
    required String origenDireccion,
    required double destinoLatitud,
    required double destinoLongitud,
    required String destinoDireccion,
    required double distanciaEstimadaKm,
    int? metodoPagoId,
  }) async {
    requestTripCalls++;
    if (requestTripError != null) throw requestTripError!;
    return requestTripResult!();
  }

  @override
  Future<Either<Failure, TripEntity>> getTripStatus({
    required int userId,
    required String codigoViaje,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> cancelTrip({
    required int userId,
    required int tripId,
    required String motivo,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> rateDriver({
    required int userId,
    required int tripId,
    required int calificacion,
    String? comentario,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, List<TripEntity>>> getAvailableTrips(int userId) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, TripEntity>> acceptTrip({
    required int userId,
    required int tripId,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> rejectTrip({
    required int userId,
    required int tripId,
    String? motivo,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, TripEntity>> startTrip({
    required int userId,
    required int tripId,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, CompleteTripResult>> completeTrip({
    required int userId,
    required int tripId,
    required double distanciaFinalKm,
    required int duracionMinutos,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> ratePassenger({
    required int userId,
    required int tripId,
    required int calificacion,
    String? comentario,
  }) => throw UnimplementedError();
}

/// No abre un socket real: solo evita que ClientTripBloc intente conectar
/// de verdad durante el test.
class _NoopTripStatusSocket extends TripStatusSocket {
  _NoopTripStatusSocket() : super(serverUrl: 'ws://fake');

  @override
  Stream<TripStatusEvent> connect(int tripId) => const Stream.empty();

  @override
  void disconnect() {}
}

class _NoopClientPositionListener extends ClientPositionListener {
  _NoopClientPositionListener()
    : super(wsManager: WebSocketManager(wsBaseUrl: 'ws://fake'));

  @override
  Stream<DriverLocationUpdate> connect(int tripId) => const Stream.empty();

  @override
  void disconnect() {}
}

TripEntity _trip({TripStatus estado = TripStatus.solicitado}) => TripEntity(
  id: 1,
  codigoViaje: 'VJ-ABCDE',
  passengerId: 7,
  cooperativaId: 1,
  origenLatitud: -0.1,
  origenLongitud: -78.5,
  origenDireccion: 'Origen',
  destinoLatitud: -0.2,
  destinoLongitud: -78.4,
  destinoDireccion: 'Destino',
  distanciaKm: 3.2,
  precioTotal: 4.5,
  estado: estado,
  fechaSolicitud: '2026-11-24T00:00:00Z',
);

void main() {
  late _FakeTripRepository repo;
  late ClientTripBloc bloc;

  setUp(() {
    repo = _FakeTripRepository();
    bloc = ClientTripBloc(
      requestTrip: RequestTripUseCase(repo),
      cancelTrip: CancelTripUseCase(repo),
      rateDriver: RateDriverUseCase(repo),
      socket: _NoopTripStatusSocket(),
      positionListener: _NoopClientPositionListener(),
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  void requestTrip() => bloc.add(
    const ClientTripRequestEvent(
      userId: 7,
      origenLatitud: -0.1,
      origenLongitud: -78.5,
      origenDireccion: 'Origen',
      destinoLatitud: -0.2,
      destinoLongitud: -78.4,
      destinoDireccion: 'Destino',
      distanciaEstimadaKm: 3.2,
    ),
  );

  group('ClientTripBloc._onRequest', () {
    test(
      'T24-C1: emite ClientTripStatus.searching tras una solicitud exitosa',
      () async {
        repo.requestTripResult = () => Right(_trip());
        final states = <ClientTripStatus>[];
        bloc.stream.listen((s) => states.add(s.status));

        requestTrip();
        await pumpEventQueue();

        expect(states, contains(ClientTripStatus.requesting));
        expect(states, contains(ClientTripStatus.searching));
        expect(bloc.state.activeTrip, isNotNull);
      },
    );

    test(
      'T24-C2: emite error con mensaje amigable si ya existe un viaje activo (409)',
      () async {
        repo.requestTripError = const ActiveTripException();

        requestTrip();
        await pumpEventQueue();

        expect(bloc.state.status, ClientTripStatus.error);
        expect(bloc.state.errorMessage, const ActiveTripException().message);
      },
    );

    test(
      'T24-C3: bloquea una nueva solicitud si ya existe un viaje en curso en el estado',
      () async {
        repo.requestTripResult = () => Right(_trip());
        requestTrip();
        await pumpEventQueue();
        expect(bloc.state.status, ClientTripStatus.searching);
        expect(repo.requestTripCalls, 1);

        // Segunda solicitud mientras el estado sigue "searching": no debe
        // llegar al repositorio.
        requestTrip();
        await pumpEventQueue();

        expect(repo.requestTripCalls, 1);
        expect(bloc.state.status, ClientTripStatus.error);
      },
    );

    test('T24-C4: emite FailureState ante un error de red', () async {
      repo.requestTripResult = () =>
          const Left(NetworkFailure(message: 'Sin conexión'));

      requestTrip();
      await pumpEventQueue();

      expect(bloc.state.status, ClientTripStatus.error);
      expect(bloc.state.errorMessage, 'Sin conexión');
    });

    test(
      'T24-C4: emite FailureState ante un conflicto de idempotencia',
      () async {
        repo.requestTripResult = () => const Left(
          IdempotencyConflictFailure(message: 'Solicitud duplicada'),
        );

        requestTrip();
        await pumpEventQueue();

        expect(bloc.state.status, ClientTripStatus.error);
        expect(bloc.state.errorMessage, 'Solicitud duplicada');
      },
    );
  });
}
