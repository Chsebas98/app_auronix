// Prueba la decision de redireccion (T3, T15) como funcion pura, sin levantar
// el arbol de widgets real: las pantallas home de /client y /driver dependen
// de varios Blocs registrados en GetIt, que no hace falta armar solo para
// probar a donde decide navegar el router.

import 'package:auronix_app/app/core/bloc/session-bloc/session_bloc.dart';
import 'package:auronix_app/app/router/app_routes.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/app/router/driver/conductor_routes_path.dart';
import 'package:auronix_app/app/router/role_redirect_guard.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:flutter_test/flutter_test.dart';

SessionAuthenticated _authenticatedAs(Roles role) => SessionAuthenticated(
  dataUser: AuthenticationCredentials.empty().copyWith(role: role),
);

void main() {
  test('T3-C1: sesion cargando no redirige', () {
    final target = resolveRedirect(
      sessionState: const SessionLoading(),
      currentLocation: ConductorRoutesPath.home,
      isPublic: false,
    );
    expect(target, isNull);
  });

  test('T3-C1: sesion expirada redirige a session_expired', () {
    final target = resolveRedirect(
      sessionState: const SessionTokenExpired(),
      currentLocation: ConductorRoutesPath.home,
      isPublic: false,
    );
    expect(target, Routes.sessionExpired);
  });

  test(
    'T15-C6: usuario no autenticado en ruta protegida es enviado a login',
    () {
      final target = resolveRedirect(
        sessionState: const SessionUnauthenticated(),
        currentLocation: ConductorRoutesPath.home,
        isPublic: false,
      );
      expect(target, Routes.auth);
    },
  );

  test('usuario no autenticado en ruta publica no redirige', () {
    final target = resolveRedirect(
      sessionState: const SessionUnauthenticated(),
      currentLocation: Routes.auth,
      isPublic: true,
    );
    expect(target, isNull);
  });

  test(
    'T15-C5: pasajero autenticado en ruta publica es enviado a /client/home',
    () {
      final target = resolveRedirect(
        sessionState: _authenticatedAs(Roles.rolUser),
        currentLocation: Routes.auth,
        isPublic: true,
      );
      expect(target, ClientRoutesPath.home);
    },
  );

  test('usuario autenticado en onBoarding se queda ahi', () {
    final target = resolveRedirect(
      sessionState: _authenticatedAs(Roles.rolUser),
      currentLocation: Routes.onBoarding,
      isPublic: true,
    );
    expect(target, isNull);
  });

  test('usuario autenticado en allow-location no redirige', () {
    final target = resolveRedirect(
      sessionState: _authenticatedAs(Roles.rolDriver),
      currentLocation: Routes.allowLocation,
      isPublic: false,
    );
    expect(target, isNull);
  });

  test(
    'T15-C5: pasajero autenticado no accede a /driver/* y es enviado a /client/home',
    () {
      final target = resolveRedirect(
        sessionState: _authenticatedAs(Roles.rolUser),
        currentLocation: ConductorRoutesPath.home,
        isPublic: false,
      );
      expect(target, ClientRoutesPath.home);
    },
  );

  test(
    'T15-C5: conductor autenticado no accede a /client/* y es enviado a /driver/home',
    () {
      final target = resolveRedirect(
        sessionState: _authenticatedAs(Roles.rolDriver),
        currentLocation: ClientRoutesPath.home,
        isPublic: false,
      );
      expect(target, ConductorRoutesPath.home);
    },
  );

  test('pasajero autenticado dentro de su propia ruta no redirige', () {
    final target = resolveRedirect(
      sessionState: _authenticatedAs(Roles.rolUser),
      currentLocation: ClientRoutesPath.profile,
      isPublic: false,
    );
    expect(target, isNull);
  });

  test('conductor autenticado dentro de su propia ruta no redirige', () {
    final target = resolveRedirect(
      sessionState: _authenticatedAs(Roles.rolDriver),
      currentLocation: ConductorRoutesPath.profile,
      isPublic: false,
    );
    expect(target, isNull);
  });
}
