import 'dart:async';

import 'package:auronix_app/app/network/websocket_manager.dart';
import 'package:auronix_app/core/errors/failure.dart';
import 'package:auronix_app/features/trips/data/datasources/socket/client_position_listener.dart';
import 'package:auronix_app/features/trips/data/datasources/socket/trip_status_socket.dart';
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

TripEntity _trip(TripStatus status) => TripEntity(
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
  estado: status,
  fechaSolicitud: '2026-11-24T00:00:00Z',
);

class _FakeTripRepository implements TripRepository {
  int requestCalls = 0;
  final ratings = <({int userId, int tripId, int rating, String? comment})>[];

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
    requestCalls++;
    return Right(_trip(TripStatus.solicitado));
  }

  @override
  Future<Either<Failure, void>> rateDriver({
    required int userId,
    required int tripId,
    required int calificacion,
    String? comentario,
  }) async {
    ratings.add((
      userId: userId,
      tripId: tripId,
      rating: calificacion,
      comment: comentario,
    ));
    return const Right(null);
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

class _FakeTripStatusSocket extends TripStatusSocket {
  _FakeTripStatusSocket() : super(serverUrl: 'ws://fake');

  final controller = StreamController<TripStatusEvent>.broadcast();
  final connectedTripId = Completer<int>();
  int disconnectCalls = 0;

  @override
  Stream<TripStatusEvent> connect(int tripId) {
    connectedTripId.complete(tripId);
    return controller.stream;
  }

  @override
  void disconnect() => disconnectCalls++;
}

class _FakeClientPositionListener extends ClientPositionListener {
  _FakeClientPositionListener()
    : super(wsManager: WebSocketManager(wsBaseUrl: 'ws://fake'));

  final controller = StreamController<DriverLocationUpdate>.broadcast();
  final connectedTripId = Completer<int>();
  int disconnectCalls = 0;

  @override
  Stream<DriverLocationUpdate> connect(int tripId) {
    connectedTripId.complete(tripId);
    return controller.stream;
  }

  @override
  void disconnect() => disconnectCalls++;
}

void main() {
  late _FakeTripRepository repo;
  late _FakeTripStatusSocket socket;
  late _FakeClientPositionListener positions;
  late ClientTripBloc bloc;

  setUp(() {
    repo = _FakeTripRepository();
    socket = _FakeTripStatusSocket();
    positions = _FakeClientPositionListener();
    bloc = ClientTripBloc(
      requestTrip: RequestTripUseCase(repo),
      cancelTrip: CancelTripUseCase(repo),
      rateDriver: RateDriverUseCase(repo),
      socket: socket,
      positionListener: positions,
    );
  });

  tearDown(() async {
    if (!bloc.isClosed) await bloc.close();
    await socket.controller.close();
    await positions.controller.close();
  });

  Future<ClientTripState> nextStatus(ClientTripStatus status) =>
      bloc.stream.firstWhere((state) => state.status == status);

  Future<void> requestTrip() async {
    final searching = nextStatus(ClientTripStatus.searching);
    bloc.add(
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
    await searching;
    expect(await socket.connectedTripId.future, 1);
  }

  void expectTrip(ClientTripState state, TripStatus tripStatus) {
    final trip = state.activeTrip;
    expect(trip, isNotNull);
    expect(trip!.id, 1);
    expect(trip.codigoViaje, 'VJ-ABCDE');
    expect(trip.passengerId, 7);
    expect(trip.origenLatitud, -0.1);
    expect(trip.origenLongitud, -78.5);
    expect(trip.origenDireccion, 'Origen');
    expect(trip.destinoLatitud, -0.2);
    expect(trip.destinoLongitud, -78.4);
    expect(trip.destinoDireccion, 'Destino');
    expect(trip.estado, tripStatus);
    expect(state.origenLatitud, -0.1);
    expect(state.origenLongitud, -78.5);
    expect(state.origenDireccion, 'Origen');
    expect(state.destinoLatitud, -0.2);
    expect(state.destinoLongitud, -78.4);
    expect(state.destinoDireccion, 'Destino');
    expect(state.distanciaEstimadaKm, 3.2);
    expect(state.errorMessage, isNull);
  }

  test('T29-C3: el flujo completo conserva los datos del viaje', () async {
    final statuses = <ClientTripStatus>[];
    final subscription = bloc.stream.listen(
      (state) => statuses.add(state.status),
    );
    final route = bloc.stream.firstWhere((state) => state.hasRoute);
    bloc.add(
      const ClientTripSetRouteEvent(
        origenLatitud: -0.1,
        origenLongitud: -78.5,
        origenDireccion: 'Origen',
        destinoLatitud: -0.2,
        destinoLongitud: -78.4,
        destinoDireccion: 'Destino',
        distanciaEstimadaKm: 3.2,
      ),
    );
    await route;
    await requestTrip();
    expect(repo.requestCalls, 1);
    expectTrip(bloc.state, TripStatus.solicitado);

    Future<void> sendStatus(
      TripStatus tripStatus,
      ClientTripStatus expectedStatus, {
      bool includeTrip = true,
    }) async {
      final next = nextStatus(expectedStatus);
      socket.controller.add(
        TripStatusEvent(
          tripId: 1,
          status: tripStatus.toBackendValue(),
          trip: includeTrip ? _trip(tripStatus) : null,
        ),
      );
      expectTrip(await next, includeTrip ? tripStatus : TripStatus.aceptado);
    }

    await sendStatus(TripStatus.aceptado, ClientTripStatus.accepted);
    bloc.add(const ClientTripListenPositionEvent(tripId: 1));
    expect(await positions.connectedTripId.future, 1);
    await sendStatus(
      TripStatus.enCurso,
      ClientTripStatus.inProgress,
      includeTrip: false,
    );
    await sendStatus(TripStatus.completado, ClientTripStatus.completed);
    expect(socket.disconnectCalls, 1);
    expect(socket.controller.hasListener, isFalse);

    final rated = nextStatus(ClientTripStatus.rated);
    bloc.add(
      const ClientTripRateDriverEvent(
        userId: 7,
        tripId: 1,
        calificacion: 5,
        comentario: 'Buen viaje',
      ),
    );
    expectTrip(await rated, TripStatus.completado);
    expect(repo.ratings, [
      (userId: 7, tripId: 1, rating: 5, comment: 'Buen viaje'),
    ]);

    await bloc.close();
    expect(socket.disconnectCalls, 2);
    expect(positions.disconnectCalls, 1);
    expect(positions.controller.hasListener, isFalse);
    expect(statuses, [
      ClientTripStatus.initial,
      ClientTripStatus.requesting,
      ClientTripStatus.searching,
      ClientTripStatus.accepted,
      ClientTripStatus.inProgress,
      ClientTripStatus.completed,
      ClientTripStatus.rating,
      ClientTripStatus.rated,
    ]);
    await subscription.cancel();
  });

  test('T29-C4: cerrar el Bloc cancela ambas suscripciones activas', () async {
    await requestTrip();
    bloc.add(const ClientTripListenPositionEvent(tripId: 1));
    expect(await positions.connectedTripId.future, 1);
    expect(socket.controller.hasListener, isTrue);
    expect(positions.controller.hasListener, isTrue);

    await bloc.close();

    expect(socket.disconnectCalls, 1);
    expect(positions.disconnectCalls, 1);
    expect(socket.controller.hasListener, isFalse);
    expect(positions.controller.hasListener, isFalse);
  });
}
