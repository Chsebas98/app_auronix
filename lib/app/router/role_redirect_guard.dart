import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/app/router/driver/conductor_routes_path.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/core/core.dart';

/// Decide la redirección de GoRouter segun el estado de sesión (T3, T15).
/// Logica pura y sin BuildContext para poder probarla sin levantar el arbol
/// de widgets real (que necesitaria todos los Blocs de GetIt registrados).
String? resolveRedirect({
  required SessionState sessionState,
  required String currentLocation,
  required bool isPublic,
}) {
  // Si está verificando sesión, dejar en la ruta actual
  if (sessionState is SessionLoading) {
    return null;
  }

  // Si no hay sesión
  if (sessionState is SessionUnauthenticated ||
      sessionState is SessionTokenExpired) {
    if (sessionState is SessionTokenExpired) {
      return Routes.sessionExpired;
    }

    if (!isPublic) {
      return Routes.auth;
    }

    return null;
  }

  // Si está autenticado
  if (sessionState is SessionAuthenticated) {
    // No redirigir si ya está en allow-location
    if (currentLocation == Routes.allowLocation) {
      return null;
    }

    final role = sessionState.dataUser.role;
    // Si está en rutas públicas y no es onBoarding
    if (isPublic && currentLocation != Routes.onBoarding) {
      return switch (role) {
        Roles.rolUser => ClientRoutesPath.home,
        Roles.rolDriver => ConductorRoutesPath.home,
        // 'socio' => SocioRoutesPath.home,
        // 'gerente' => GerenteRoutesPath.home,
        // 'superadmin' => SuperAdminRoutesPath.home,
        _ => Routes.root,
      };
    }

    // Si está en onBoarding, dejarlo ahí
    if (currentLocation == Routes.onBoarding) {
      return null;
    }

    // T15: un rol no puede entrar a las rutas protegidas del otro rol
    // (ej. un pasajero no puede acceder a /driver/*).
    if (role == Roles.rolUser &&
        currentLocation.startsWith(ConductorRoutesPath.base)) {
      return ClientRoutesPath.home;
    }
    if (role == Roles.rolDriver &&
        currentLocation.startsWith(ClientRoutesPath.base)) {
      return ConductorRoutesPath.home;
    }
  }

  return null;
}
