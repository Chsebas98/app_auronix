import 'package:auronix_app/app/core/bloc/session-bloc/session_bloc.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/app/environments/flavors/env_base_config.dart';
import 'package:auronix_app/app/router/app_router.dart';
import 'package:auronix_app/app/router/app_routes.dart';
import 'package:auronix_app/app/router/client/client_routes.dart';
import 'package:auronix_app/app/router/driver/conductor_routes.dart';
import 'package:auronix_app/features/home/presentation/pages/health_check_screen.dart';
import 'package:auronix_app/shared/pages/not_found_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUpAll(() async {
    // EnvDevConfig lee sus valores de dotenv.env; sin cargar el .env primero,
    // Environment()..initConfig(Environment.dev) lanza NotInitializedError.
    await dotenv.load(fileName: '.env.dev');
  });

  setUp(() async {
    await sl.reset();
    final environment = Environment()..initConfig(Environment.dev);
    sl.registerSingleton<Environment>(environment);
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets(
    'T3-C1 T3-C3 T3-C5: /health navega a diagnostico sin errores de contexto',
    (tester) async {
      _initializeRouter();
      AppRouter.go(Routes.health);

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: AppRouter.instance),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HealthCheckScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      AppRouter.instance.dispose();
    },
  );

  testWidgets('T3-C2 T3-C6: muestra ambiente, API y URL WebSocket configurados', (
    tester,
  ) async {
    final environment = sl<Environment>();
    environment.config = _TestEnvironmentConfig('https://api.example.test/api');
    final apiUrl = environment.config!.apiBaseUrl;
    final apiUri = Uri.parse(apiUrl);
    final expectedWebSocketUrl = apiUri
        .replace(
          scheme: apiUri.scheme == 'https' ? 'wss' : 'ws',
          path: '',
          query: null,
          fragment: null,
        )
        .toString();

    await tester.pumpWidget(
      const MaterialApp(home: HealthCheckScreen()),
    );

    expect(find.text('Ambiente: DEV'), findsOneWidget);
    expect(find.text('API URL: $apiUrl'), findsOneWidget);
    expect(find.text('WebSocket: $expectedWebSocketUrl'), findsOneWidget);

    environment.config = _TestEnvironmentConfig('http://api.example.test/api');
    await tester.pumpWidget(
      const MaterialApp(home: HealthCheckScreen()),
    );
    expect(find.text('WebSocket: ws://api.example.test'), findsOneWidget);
  });

  testWidgets('T3-C4: rutas inexistentes muestran NotFoundScreen', (
    tester,
  ) async {
    _initializeRouter();
    AppRouter.go('/ruta-inexistente');

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: AppRouter.instance),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NotFoundScreen), findsOneWidget);
    expect(find.text('Ruta no encontrada (404)'), findsOneWidget);
    AppRouter.instance.dispose();
  });

  test('T3-C7: las ramas de cliente y conductor siguen desacopladas', () {
    final rootNavKey = GlobalKey<NavigatorState>();
    final clientPaths = _routePaths(
      ClientRoutes.routes(rootNavKey: rootNavKey),
    );
    final conductorPaths = _routePaths(
      ConductorRoutes.routes(rootNavKey: rootNavKey),
    );

    expect(clientPaths.every((path) => path.startsWith('/client/')), isTrue);
    expect(conductorPaths.every((path) => path.startsWith('/driver/')), isTrue);
    expect(clientPaths.toSet().intersection(conductorPaths.toSet()), isEmpty);
  });
}

void _initializeRouter() {
  AppRouter.initialize(
    _UnauthenticatedSessionBloc(),
    GlobalKey<NavigatorState>(),
  );
}

List<String> _routePaths(Iterable<RouteBase> routes) {
  final paths = <String>[];
  for (final route in routes) {
    if (route is GoRoute) {
      paths
        ..add(route.path)
        ..addAll(_routePaths(route.routes));
    } else if (route is ShellRoute) {
      paths.addAll(_routePaths(route.routes));
    }
  }
  return paths;
}

class _UnauthenticatedSessionBloc implements SessionBloc {
  @override
  SessionState get state => const SessionUnauthenticated();

  @override
  Stream<SessionState> get stream => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestEnvironmentConfig implements EnvBaseConfig {
  _TestEnvironmentConfig(this.apiBaseUrl);

  @override
  final String apiBaseUrl;

  @override
  String get googleMapsApiKey => '';

  @override
  String get tokenKey => '';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
