import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/features/home/presentation/pages/client/client_home_page.dart';
import 'package:auronix_app/features/home/presentation/templates/client/client_shell_template.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

abstract final class ClientRoutes {
  static List<RouteBase> routes({
    required GlobalKey<NavigatorState> rootNavKey,
  }) => [
    ShellRoute(
      navigatorKey: GlobalKey<NavigatorState>(),
      builder: (context, state, child) => ClientShellTemplate(child: child),
      routes: [
        GoRoute(
          path: ClientRoutesPath.home,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ClientHomePage()),
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
