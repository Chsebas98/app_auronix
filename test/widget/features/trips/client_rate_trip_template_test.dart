// Prueba ClientRateTripTemplate (T28): el formulario de calificacion solo
// se muestra si el viaje realmente termino (T28-C1), el envio exige una
// calificacion seleccionada (T28-C2), aparece de inmediato al completarse
// el viaje (T28-C3), y la llamada real maneja tanto el exito como un
// error de red mostrando el mensaje via DialogCubit (T28-C4) — antes de
// este cambio, un error dejaba el Bloc atascado en status.rating para
// siempre (ningun listener escuchaba ese estado), bug corregido en
// ClientTripBloc._onRateDriver junto con este test.

import 'dart:convert';

import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/app/design/theme/app_theme.dart';
import 'package:auronix_app/app/network/websocket_manager.dart';
import 'package:auronix_app/core/errors/failure.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
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
import 'package:auronix_app/features/trips/presentation/templates/client/client_rate_trip_template.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class _FakeTripRepository implements TripRepository {
  int rateDriverCalls = 0;
  int? userId;
  int? tripId;
  int? calificacion;
  String? comentario;
  Either<Failure, void> Function()? rateDriverResult;

  @override
  Future<Either<Failure, void>> rateDriver({
    required int userId,
    required int tripId,
    required int calificacion,
    String? comentario,
  }) async {
    rateDriverCalls++;
    this.userId = userId;
    this.tripId = tripId;
    this.calificacion = calificacion;
    this.comentario = comentario;
    return rateDriverResult!();
  }

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
  }) => throw UnimplementedError();

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

class _NoopAuthRepository extends Fake implements AuthUnifiedRepository {}

class _NoopPreferences extends Fake implements RxSharedPreferences {}

TripEntity _trip() => const TripEntity(
  id: 42,
  codigoViaje: 'VJ-ABCDE',
  passengerId: 7,
  driverId: 9,
  cooperativaId: 1,
  origenLatitud: -0.1,
  origenLongitud: -78.5,
  origenDireccion: 'Origen',
  destinoLatitud: -0.2,
  destinoLongitud: -78.4,
  destinoDireccion: 'Destino',
  distanciaKm: 3.2,
  precioTotal: 4.5,
  estado: TripStatus.completado,
  fechaSolicitud: '2026-11-24T00:00:00Z',
);

void main() {
  late _FakeTripRepository repo;
  late ClientTripBloc tripBloc;
  late SessionBloc sessionBloc;
  late DialogCubit dialogCubit;
  late GoRouter router;

  setUp(() {
    repo = _FakeTripRepository();
    tripBloc = ClientTripBloc(
      requestTrip: RequestTripUseCase(repo),
      cancelTrip: CancelTripUseCase(repo),
      rateDriver: RateDriverUseCase(repo),
      socket: _NoopTripStatusSocket(),
      positionListener: _NoopClientPositionListener(),
    );
    sessionBloc = SessionBloc(_NoopAuthRepository(), _NoopPreferences());
    dialogCubit = DialogCubit();
    final payload = base64Url.encode(utf8.encode('{"sub":7}'));
    sessionBloc.add(
      LoginUserEvent(
        dataUser: const AuthenticationCredentials.empty().copyWith(
          tokenAccess: 'test.$payload.signature',
        ),
      ),
    );
    router = GoRouter(
      initialLocation: '/rate',
      routes: [
        GoRoute(
          path: '/rate',
          builder: (_, __) => const ClientRateTripTemplate(),
        ),
        GoRoute(
          path: ClientRoutesPath.tripCompleted,
          builder: (_, __) => const Scaffold(body: Text('Viaje completado')),
        ),
      ],
    );
  });

  tearDown(() async {
    router.dispose();
    await sessionBloc.close();
    await dialogCubit.close();
    await tripBloc.close();
  });

  Widget wrap() => MultiBlocProvider(
    providers: [
      BlocProvider.value(value: tripBloc),
      BlocProvider.value(value: sessionBloc),
      BlocProvider.value(value: dialogCubit),
    ],
    child: ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) =>
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );

  testWidgets('T28-C1: el formulario no se muestra si el viaje sigue activo', (
    tester,
  ) async {
    // ignore: invalid_use_of_visible_for_testing_member
    tripBloc.emit(
      ClientTripState(status: ClientTripStatus.inProgress, activeTrip: _trip()),
    );
    await tester.pumpWidget(wrap());

    expect(find.text('¿Cómo fue tu conductor?'), findsNothing);
    expect(find.byIcon(Icons.star_outline_rounded), findsNothing);
  });

  testWidgets(
    'T28-C3: el formulario aparece de inmediato en cuanto el viaje esta COMPLETADO',
    (tester) async {
      // ignore: invalid_use_of_visible_for_testing_member
      tripBloc.emit(
        ClientTripState(
          status: ClientTripStatus.completed,
          activeTrip: _trip(),
        ),
      );
      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(find.text('¿Cómo fue tu conductor?'), findsOneWidget);
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));
    },
  );

  testWidgets(
    'T28-C2: el boton de enviar esta deshabilitado hasta seleccionar una calificacion',
    (tester) async {
      repo.rateDriverResult = () => const Right(null);
      // ignore: invalid_use_of_visible_for_testing_member
      tripBloc.emit(
        ClientTripState(
          status: ClientTripStatus.completed,
          activeTrip: _trip(),
        ),
      );
      await tester.pumpWidget(wrap());
      await tester.pump();

      await tester.tap(find.text('ENVIAR CALIFICACIÓN'));
      await tester.pump();
      expect(repo.rateDriverCalls, 0);

      await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
      await tester.pump();
      await tester.tap(find.text('ENVIAR CALIFICACIÓN'));
      for (var i = 0; i < 5; i++) {
        await tester.pump();
      }
      expect(repo.rateDriverCalls, 1);
    },
  );

  testWidgets(
    'T28-C4: envia los datos correctos y, ante un error de red, muestra el mensaje y permite reintentar',
    (tester) async {
      repo.rateDriverResult = () =>
          const Left(NetworkFailure(message: 'Sin conexión'));
      // ignore: invalid_use_of_visible_for_testing_member
      tripBloc.emit(
        ClientTripState(
          status: ClientTripStatus.completed,
          activeTrip: _trip(),
        ),
      );
      await tester.pumpWidget(wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.star_outline_rounded).at(2));
      await tester.pump();
      await tester.tap(find.text('ENVIAR CALIFICACIÓN'));
      // El spinner de AppButton (CircularProgressIndicator.adaptive, que
      // gira indefinidamente mientras isLoading) impide que tester.pump()
      // drene el await de _onRateDriver sobre el Future del repositorio
      // fake — mismo problema que la animacion de pulso en el test de
      // T26. runAsync() deja que el Future resuelva con el scheduler real.
      await tester.runAsync(
        () => tripBloc.stream.firstWhere(
          (s) => s.status == ClientTripStatus.error,
        ),
      );
      await tester.pump();

      expect(repo.userId, 7);
      expect(repo.tripId, 42);
      expect(repo.calificacion, 3);
      expect(dialogCubit.state, isA<DialogMessage>());
      expect((dialogCubit.state as DialogMessage).message, 'Sin conexión');

      // El bug corregido: el estado debe salir de "rating" para que el
      // boton vuelva a estar habilitado y se pueda reintentar.
      expect(tripBloc.state.status, ClientTripStatus.error);
      await tester.tap(find.text('ENVIAR CALIFICACIÓN'));
      await tester.pump();
      expect(repo.rateDriverCalls, 2);
    },
  );
}
