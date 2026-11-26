import 'dart:async';

import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/data/datasources/socket/client_position_listener.dart';
import 'package:auronix_app/features/trips/data/datasources/socket/trip_status_socket.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_socket_events.dart';
import 'package:auronix_app/features/trips/domain/repository/trip_repository.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/cancel_trip_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/rate_driver_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/request_trip_usecase.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const trip = TripEntity(
    id: 42,
    codigoViaje: 'TRIP-42',
    passengerId: 7,
    cooperativaId: 3,
    origenLatitud: 1,
    origenLongitud: 2,
    origenDireccion: 'Origin',
    destinoLatitud: 3,
    destinoLongitud: 4,
    destinoDireccion: 'Destination',
    distanciaKm: 5,
    precioTotal: 10,
    estado: 'BUSCANDO',
    fechaSolicitud: '2026-01-01',
  );

  ClientTripBloc createBloc(_FakeTripStatusSocket socket) {
    final repository = _TripRepositoryStub(trip);
    return ClientTripBloc(
      requestTrip: RequestTripUseCase(repository),
      cancelTrip: CancelTripUseCase(repository),
      rateDriver: RateDriverUseCase(repository),
      socket: socket,
      positionListener: ClientPositionListener(serverUrl: 'ws://localhost'),
    );
  }

  Future<void> requestTrip(ClientTripBloc bloc) async {
    bloc.add(const ClientTripRequestEvent(
      userId: 7,
      origenLatitud: 1,
      origenLongitud: 2,
      origenDireccion: 'Origin',
      destinoLatitud: 3,
      destinoLongitud: 4,
      destinoDireccion: 'Destination',
      distanciaEstimadaKm: 5,
    ));
  }

  test('T25-C3 connects to the newly created trip after a successful request',
      () async {
    final socket = _FakeTripStatusSocket();
    final bloc = createBloc(socket);

    await requestTrip(bloc);

    expect(await socket.connectedTripId.future, trip.id);
    expect(bloc.state.status, ClientTripStatus.searching);
  });

  test('T25-C1 T25-C4 maps socket events to passenger trip status changes',
      () async {
    final socket = _FakeTripStatusSocket();
    final bloc = createBloc(socket);
    await requestTrip(bloc);
    await socket.connectedTripId.future;

    Future<void> expectSocketStatus(String status, ClientTripStatus expected) {
      final expectedState = expectLater(
        bloc.stream,
        emitsThrough(
          predicate<ClientTripState>((state) => state.status == expected),
        ),
      );
      socket.controller.add(TripStatusEvent(tripId: trip.id, status: status));
      return expectedState;
    }

    await expectSocketStatus('ACEPTADO', ClientTripStatus.accepted);
    await expectSocketStatus('EN_CURSO', ClientTripStatus.inProgress);
    await expectSocketStatus('COMPLETADO', ClientTripStatus.completed);

    expect(bloc.state.status, ClientTripStatus.completed);
    expect(socket.disconnectCalls, 1);
  });
}

class _FakeTripStatusSocket extends TripStatusSocket {
  _FakeTripStatusSocket()
      : controller = StreamController<TripStatusEvent>.broadcast(),
        super(serverUrl: 'ws://localhost');

  final StreamController<TripStatusEvent> controller;
  final connectedTripId = Completer<int>();
  int disconnectCalls = 0;

  @override
  Stream<TripStatusEvent> connect(int tripId) {
    connectedTripId.complete(tripId);
    return controller.stream;
  }

  @override
  void disconnect() {
    disconnectCalls++;
  }
}

class _TripRepositoryStub implements TripRepository {
  _TripRepositoryStub(this.trip);

  final TripEntity trip;

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
  }) async =>
      Right(trip);

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
