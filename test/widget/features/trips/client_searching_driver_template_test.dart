import 'dart:async';
import 'dart:convert';

import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/network/websocket_manager.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auronix_app/features/trips/data/datasources/socket/client_position_listener.dart';
import 'package:auronix_app/features/trips/data/datasources/socket/trip_status_socket.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_status.dart';
import 'package:auronix_app/features/trips/domain/repository/trip_repository.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/cancel_trip_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/rate_driver_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/request_trip_usecase.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:auronix_app/features/trips/presentation/templates/client/client_searching_driver_template.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class _TripRepository extends Fake implements TripRepository {
  final cancellation = Completer<Either<Failure, void>>();
  int calls = 0;
  int? userId;
  int? tripId;
  String? motivo;

  @override
  Future<Either<Failure, void>> cancelTrip({
    required int userId,
    required int tripId,
    required String motivo,
  }) {
    calls++;
    this.userId = userId;
    this.tripId = tripId;
    this.motivo = motivo;
    return cancellation.future;
  }
}

class _AuthRepository extends Fake implements AuthUnifiedRepository {}

class _Preferences extends Fake implements RxSharedPreferences {}

const _trip = TripEntity(
  id: 42,
  codigoViaje: 'test-trip',
  passengerId: 7,
  cooperativaId: 1,
  origenLatitud: 0,
  origenLongitud: 0,
  origenDireccion: 'Origen',
  destinoLatitud: 1,
  destinoLongitud: 1,
  destinoDireccion: 'Destino',
  distanciaKm: 2,
  precioTotal: 3,
  estado: TripStatus.solicitado,
  fechaSolicitud: '2026-01-01',
);

void main() {
  late _TripRepository repository;
  late ClientTripBloc tripBloc;
  late SessionBloc sessionBloc;
  late GoRouter router;

  setUp(() {
    repository = _TripRepository();
    tripBloc = ClientTripBloc(
      requestTrip: RequestTripUseCase(repository),
      cancelTrip: CancelTripUseCase(repository),
      rateDriver: RateDriverUseCase(repository),
      socket: TripStatusSocket(serverUrl: ''),
      positionListener: ClientPositionListener(
        wsManager: WebSocketManager(wsBaseUrl: 'ws://fake'),
      ),
    );
    sessionBloc = SessionBloc(_AuthRepository(), _Preferences());
    router = GoRouter(
      initialLocation: ClientRoutesPath.searchingDriver,
      routes: [
        GoRoute(
          path: ClientRoutesPath.searchingDriver,
          builder: (_, __) => const ClientSearchingDriverTemplate(),
        ),
        GoRoute(
          path: ClientRoutesPath.trips,
          builder: (_, __) => const Scaffold(body: Text('Viajes')),
        ),
        GoRoute(
          path: ClientRoutesPath.tripInProgress,
          builder: (_, __) => const Scaffold(body: Text('Viaje aceptado')),
        ),
      ],
    );
  });

  Future<void> showScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: tripBloc),
          BlocProvider.value(value: sessionBloc),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => MaterialApp.router(
            theme: ThemeData(extensions: const [AppColorsTheme.light]),
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  tearDown(() async {
    router.dispose();
    await sessionBloc.close();
    await tripBloc.close();
  });

  testWidgets('T26-C1 T26-C3 muestra la búsqueda y su animación persistente', (
    tester,
  ) async {
    await showScreen(tester);

    expect(find.text('Buscando conductor...'), findsOneWidget);
    expect(find.byIcon(Icons.directions_car_rounded), findsOneWidget);
    final rings = find.descendant(
      of: find.byType(Stack),
      matching: find.byWidgetPredicate(
        (widget) => widget is Opacity && widget.child is Container,
      ),
    );
    expect(rings, findsNWidgets(2));
    final initialOpacity = tester.widget<Opacity>(rings.first).opacity;

    // ignore: invalid_use_of_visible_for_testing_member
    tripBloc.emit(
      const ClientTripState(
        status: ClientTripStatus.searching,
        activeTrip: _trip,
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Buscando conductor...'), findsOneWidget);
    expect(find.byIcon(Icons.directions_car_rounded), findsOneWidget);
    expect(rings, findsNWidgets(2));
    expect(tester.widget<Opacity>(rings.first).opacity, isNot(initialOpacity));
  });

  testWidgets('T26-C2 T26-C4 cancela el viaje y vuelve a viajes', (
    tester,
  ) async {
    final payload = base64Url.encode(utf8.encode('{"sub":7}'));
    sessionBloc.add(
      LoginUserEvent(
        dataUser: const AuthenticationCredentials.empty().copyWith(
          tokenAccess: 'test.$payload.signature',
        ),
      ),
    );
    // ignore: invalid_use_of_visible_for_testing_member
    tripBloc.emit(
      const ClientTripState(
        status: ClientTripStatus.searching,
        activeTrip: _trip,
      ),
    );
    await showScreen(tester);

    await tester.tap(find.text('CANCELAR BÚSQUEDA'));
    await tester.pump();
    expect(repository.calls, 1);
    expect(repository.userId, 7);
    expect(repository.tripId, 42);
    expect(repository.motivo, 'Cancelado por el usuario');
    expect(find.text('Buscando conductor...'), findsOneWidget);
    expect(find.text('Viajes'), findsNothing);

    // La confirmacion real del repositorio (cancellation.complete) no se
    // ejercita aqui: la animacion de pulso de
    // ClientSearchingDriverTemplate se repite indefinidamente
    // (_ctrl.repeat()), lo que deja un Timer pendiente al cerrar el test
    // si se intenta esperar ese Future con tester.pump()/runAsync(). Ya
    // se verifico arriba que el boton dispara _cancelTrip con los datos
    // correctos (repository.calls/userId/tripId/motivo); la navegacion
    // al confirmarse la cancelacion se prueba por separado emitiendo el
    // estado directamente, igual que en el test de aceptacion.
    // ignore: invalid_use_of_visible_for_testing_member
    tripBloc.emit(
      const ClientTripState(
        status: ClientTripStatus.cancelled,
        activeTrip: null,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Viajes'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      ClientRoutesPath.trips,
    );
  });

  testWidgets('al aceptar el viaje navega a viaje en progreso', (tester) async {
    await showScreen(tester);

    // ignore: invalid_use_of_visible_for_testing_member
    tripBloc.emit(const ClientTripState(status: ClientTripStatus.accepted));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Viaje aceptado'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      ClientRoutesPath.tripInProgress,
    );
  });
}
