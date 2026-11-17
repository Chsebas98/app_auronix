import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/features/home/presentation/pages/client/client_home_page.dart';
import 'package:auronix_app/features/home/presentation/templates/client/client_shell_template.dart';
import 'package:auronix_app/features/client/presentation/pages/client_profile_page.dart';
import 'package:auronix_app/features/client/presentation/pages/client_save_trips_page.dart';
import 'package:auronix_app/features/trips/presentation/pages/client/client_confirm_trip_page.dart';
import 'package:auronix_app/features/trips/presentation/pages/client/client_rate_trip_page.dart';
import 'package:auronix_app/features/trips/presentation/pages/client/client_searching_driver_page.dart';
import 'package:auronix_app/features/trips/presentation/pages/client/client_select_destination_page.dart';
import 'package:auronix_app/features/trips/presentation/pages/client/client_start_trip_page.dart';
import 'package:auronix_app/features/trips/presentation/pages/client/client_trip_completed_page.dart';
import 'package:auronix_app/features/trips/presentation/pages/client/client_trip_in_progress_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

abstract final class ClientRoutes {
  static List<RouteBase> routes({
    required GlobalKey<NavigatorState> rootNavKey,
  }) =>
      [
        // ── Flujo de viaje (pantalla completa, fuera del ShellRoute) ───────
        GoRoute(
          path: ClientRoutesPath.selectDestination,
          parentNavigatorKey: rootNavKey,
          builder: (context, state) => const ClientSelectDestinationPage(),
        ),
        GoRoute(
          path: ClientRoutesPath.confirmTrip,
          parentNavigatorKey: rootNavKey,
          builder: (context, state) => const ClientConfirmTripPage(),
        ),
        GoRoute(
          path: ClientRoutesPath.searchingDriver,
          parentNavigatorKey: rootNavKey,
          builder: (context, state) => const ClientSearchingDriverPage(),
        ),
        GoRoute(
          path: ClientRoutesPath.tripInProgress,
          parentNavigatorKey: rootNavKey,
          builder: (context, state) => const ClientTripInProgressPage(),
        ),
        GoRoute(
          path: ClientRoutesPath.rateTrip,
          parentNavigatorKey: rootNavKey,
          builder: (context, state) => const ClientRateTripPage(),
        ),
        GoRoute(
          path: ClientRoutesPath.tripCompleted,
          parentNavigatorKey: rootNavKey,
          builder: (context, state) => const ClientTripCompletedPage(),
        ),

        // ── Shell con bottom nav ────────────────────────────────────────────
        ShellRoute(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context, state, child) =>
              ClientShellTemplate(child: child),
          routes: [
            GoRoute(
              path: ClientRoutesPath.home,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ClientHomePage()),
            ),
            GoRoute(
              path: ClientRoutesPath.trips,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ClientStartTripPage()),
            ),
            GoRoute(
              path: ClientRoutesPath.saveTrips,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ClientSaveTripsPage()),
            ),
          ],
        ),

        // ── Perfil (fullscreen, fuera del ShellRoute) ──────────────────────
        GoRoute(
          path: ClientRoutesPath.profile,
          parentNavigatorKey: rootNavKey,
          builder: (context, state) => const ClientProfilePage(),
        ),
      ];
}
