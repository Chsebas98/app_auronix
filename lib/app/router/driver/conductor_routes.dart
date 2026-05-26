import 'package:auronix_app/app/router/driver/conductor_routes_path.dart';
import 'package:auronix_app/features/home/presentation/pages/driver/driver_home_page.dart';
import 'package:auronix_app/features/home/presentation/pages/driver/driver_metrics_page.dart';
import 'package:auronix_app/features/home/presentation/templates/driver/conductor_shell_template.dart';
import 'package:auronix_app/features/trips/presentation/pages/driver/driver_rate_trip_page.dart';
import 'package:auronix_app/features/trips/presentation/pages/driver/driver_start_trip_page.dart';
import 'package:auronix_app/features/trips/presentation/pages/driver/driver_trip_completed_page.dart';
import 'package:auronix_app/features/trips/presentation/pages/driver/driver_trip_in_progress_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

abstract final class ConductorRoutes {
  static List<RouteBase> routes({
    required GlobalKey<NavigatorState> rootNavKey,
  }) => [
    // ── Flujo de viaje (pantalla completa, fuera del ShellRoute) ────────────
    GoRoute(
      path: ConductorRoutesPath.tripInProgress,
      parentNavigatorKey: rootNavKey,
      builder: (context, state) => const DriverTripInProgressPage(),
    ),
    GoRoute(
      path: ConductorRoutesPath.rateTrip,
      parentNavigatorKey: rootNavKey,
      builder: (context, state) => const DriverRateTripPage(),
    ),
    GoRoute(
      path: ConductorRoutesPath.tripCompleted,
      parentNavigatorKey: rootNavKey,
      builder: (context, state) => const DriverTripCompletedPage(),
    ),

    // ── Shell con bottom nav ─────────────────────────────────────────────────
    ShellRoute(
      navigatorKey: GlobalKey<NavigatorState>(),
      builder: (context, state, child) => ConductorShellTemplate(child: child),
      routes: [
        GoRoute(
          path: ConductorRoutesPath.home,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DriverHomePage()),
        ),
        GoRoute(
          path: ConductorRoutesPath.startTrips,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DriverStartTripPage()),
        ),
        GoRoute(
          path: ConductorRoutesPath.metrics,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DriverMetricsPage()),
        ),
        GoRoute(
          path: ConductorRoutesPath.vehicle,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DriverHomePage()),
        ),
      ],
    ),
  ];
}
