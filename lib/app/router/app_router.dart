import 'dart:async';

import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/features/conductor/routes/conductor_routes.dart';
import 'package:auronix_app/features/conductor/routes/conductor_routes_path.dart';
import 'package:auronix_app/features/features.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _publicRoutes = <String>{
  Routes.onBoarding,
  Routes.about,
  Routes.auth,
  Routes.register,
  Routes.login,
  Routes.newVersion,
  Routes.root,
  Routes.sessionExpired,
  ConductorRoutesPath.login,
};

final _publicPrefixes = <String>{'/recuperar-password'};

class AppRouter {
  static late GoRouter _router;
  static GoRouter get instance => _router;

  static void initialize(
    SessionBloc sessionBloc,
    GlobalKey<NavigatorState> rootNavKey,
  ) {
    _router = GoRouter(
      navigatorKey: rootNavKey,
      initialLocation: Routes.onBoarding,
      refreshListenable: GoRouterRefreshBloc(sessionBloc.stream),
      // errorBuilder: (context, state) => const NotFoundScreen(),
      redirect: (context, state) {
        final sessionState = sessionBloc.state;
        final currentLocation = state.uri.path;

        final isPublic =
            _publicRoutes.contains(currentLocation) ||
            _publicPrefixes.any((p) => currentLocation.contains(p));

        debugPrint('Router redirect:');
        debugPrint('Ruta: $currentLocation');
        debugPrint('Estado: ${sessionState.runtimeType}');

        // Si está verificando sesión, dejar en la ruta actual
        if (sessionState is SessionLoading) {
          debugPrint('Loading... manteniendo ruta');
          return null;
        }

        // Si no hay sesión
        if (sessionState is SessionUnauthenticated ||
            sessionState is SessionTokenExpired) {
          if (sessionState is SessionTokenExpired) {
            debugPrint('Token expirado → /session_expired');
            return Routes.sessionExpired;
          }

          if (!isPublic) {
            debugPrint('No autenticado → /auth');
            return Routes.auth;
          }

          // debugPrint('Ya en ruta pública');
          return null;
        }

        //Si está autenticado y en ruta pública
        if (sessionState is SessionAuthenticated) {
          // No redirigir si ya está en allow-location
          if (currentLocation == Routes.allowLocation) {
            return null;
          }

          // Si está en rutas públicas y no es onBoarding
          if (isPublic && currentLocation != Routes.onBoarding) {
            debugPrint('Autenticado → /home');
            return ClientRoutesPath.home;
          }

          // Si está en onBoarding, dejarlo ahí
          if (currentLocation == Routes.onBoarding) {
            debugPrint('En onboarding, esperando acción del usuario');
            return null;
          }
        }

        debugPrint('Sin redirect');
        return null;
      },
      routes: [
        //Generales
        GoRoute(
          name: 'allowLocation',
          path: Routes.allowLocation,
          builder: (context, state) {
            return AllowPermitsScreen();
          },
        ),
        //Protegidas - Cliente
        GoRoute(
          name: 'onBoarding',
          path: Routes.onBoarding,
          builder: (context, state) {
            return OnBoardingScreen();
          },
        ),
        GoRoute(
          name: 'about',
          path: Routes.about,
          builder: (context, state) {
            return AboutScreen();
          },
        ),
        GoRoute(
          name: 'authClient',
          path: Routes.auth,
          builder: (context, state) {
            return AuthScreen();
          },
        ),

        GoRoute(
          name: 'root',
          path: Routes.root,
          builder: (context, state) {
            return RootScreen();
          },
        ),

        ...ClientRoutes.routes(rootNavKey: rootNavKey),
        //Protegidas - Conductor
        ...ConductorRoutes.routes(rootNavKey: rootNavKey),

        //Protegidas - Socio

        //Protegidas - Gerente
        //Protegidas - SuperAdming
      ],
    );
  }

  // ========================================
  // 🚀 MÉTODOS DE NAVEGACIÓN
  // ========================================

  /// Navegación limpia: Reemplaza toda la pila de navegación
  /// Usa cuando: Cambias de sección principal (login → home, logout, etc.)
  static void go(String location, {Object? extra}) {
    // debugPrint('GO → $location');
    _router.go(location, extra: extra);
  }

  /// Navegación apilada: Añade una nueva ruta sobre la actual
  /// Usa cuando: Abres detalles, formularios, pantallas que permiten volver
  /// Retorna un resultado opcional cuando se hace pop
  static Future<T?> push<T>(String location, {Object? extra}) {
    // debugPrint('PUSH → $location');
    return _router.push<T>(location, extra: extra);
  }

  /// Reemplaza la ruta actual sin añadir a la pila
  /// Usa cuando: Rediriges después de una acción (crear → detalle, loading → result)
  /// El botón back NO volverá a la pantalla anterior
  static Future<T?> replace<T>(String location, {Object? extra}) {
    // debugPrint('REPLACE → $location');
    return _router.replace<T>(location, extra: extra);
  }

  /// Volver a la pantalla anterior
  /// Usa cuando: Cierras la pantalla actual
  /// Opcionalmente puedes pasar un resultado
  static void pop<T>([T? result]) {
    // debugPrint('POP ${result != null ? "con resultado" : ""}');
    if (_router.canPop()) {
      _router.pop<T>(result);
    } else {
      debugPrint('No se puede hacer pop, navegando a home');
      go(ClientRoutesPath.home);
    }
  }

  /// Verifica si se puede hacer pop
  static bool canPop() {
    return _router.canPop();
  }

  /// Pop hasta llegar a cierta ruta
  /// Usa cuando: Quieres volver a una ruta específica en la pila
  static void popUntil(String location) {
    // debugPrint('POP UNTIL → $location');
    while (_router.canPop()) {
      final currentLocation =
          _router.routerDelegate.currentConfiguration.uri.path;
      if (currentLocation == location) break;
      _router.pop();
    }
  }

  /// Navega y limpia toda la pila hasta la raíz
  /// Usa cuando: Logout, finish flow completo
  static void goAndClear(String location, {Object? extra}) {
    // debugPrint('GO AND CLEAR → $location');
    go(location, extra: extra);
  }

  /// Obtiene la ubicación actual
  static String get currentLocation {
    return _router.routerDelegate.currentConfiguration.uri.path;
  }
}

class GoRouterRefreshBloc extends ChangeNotifier {
  GoRouterRefreshBloc(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
