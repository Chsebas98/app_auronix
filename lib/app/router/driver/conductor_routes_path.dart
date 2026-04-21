import 'package:auronix_app/app/router/driver/conductor_routes.dart';
import 'package:auronix_app/features/home/presentation/pages/driver/conductor_home_page.dart';
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
              const NoTransitionPage(child: ConductorHomePage()),
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
