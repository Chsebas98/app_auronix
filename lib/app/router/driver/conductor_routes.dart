import 'package:auronix_app/app/router/driver/conductor_routes_path.dart';
import 'package:auronix_app/features/home/presentation/pages/driver/driver_home_page.dart';
import 'package:auronix_app/features/home/presentation/pages/driver/driver_metrics_page.dart';
import 'package:auronix_app/features/home/presentation/templates/driver/conductor_shell_template.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

abstract final class ConductorRoutes {
  static List<RouteBase> routes({
    required GlobalKey<NavigatorState> rootNavKey,
  }) => [
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
          path: ConductorRoutesPath.trips,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DriverHomePage()),
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

        // GoRoute(
        //   path: ClientRoutesPath.profile,
        //   pageBuilder: (context, state) => const NoTransitionPage(
        //     child: ClientProfilePage(),
        //   ),
        // ),
        // GoRoute(
        //   path: ClientRoutesPath.trip,
        //   builder: (context, state) => const TripPage(),
        // ),
      ],
    ),
  ];
}
