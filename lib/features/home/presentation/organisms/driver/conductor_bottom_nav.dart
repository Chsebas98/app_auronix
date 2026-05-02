import 'package:auronix_app/app/router/driver/conductor_routes_path.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:auronix_app/shared/templates/appbar/bottom-appbar/cubit/bottom_nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ConductorBottomNav extends StatelessWidget {
  const ConductorBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<BottomNavCubit, BottomNavState>(
      builder: (context, navState) {
        _syncIndexWithRoute(context);
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.primaryColor,
            border: Border(
              top: BorderSide(color: theme.dividerColor, width: 1),
            ),
          ),
          child: AppBottomNav(
            // ← atom/molecule de shared
            role: Roles.rolDriver,
            currentIndex: navState.currentIndex,
            onTap: (index) {
              context.read<BottomNavCubit>().setIndex(index);
              _navigateToIndex(context, index);
            },
          ),
        );
      },
    );
  }

  void _syncIndexWithRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final cubit = context.read<BottomNavCubit>();

    final newIndex = switch (true) {
      _ when location.startsWith(ConductorRoutesPath.home) => 0,
      _ when location.startsWith(ConductorRoutesPath.startTrips) => 1,
      _ when location.startsWith(ConductorRoutesPath.metrics) => 2,
      _ when location.startsWith(ConductorRoutesPath.vehicle) => 3,
      _ => 0,
    };

    if (cubit.state.currentIndex != newIndex) {
      cubit.setIndex(newIndex);
    }
  }

  void _navigateToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.push(ConductorRoutesPath.home);
      // case 1:
      //   context.push(ConductorRoutesPath.messages, extra: Roles.rolDriver);
      case 1:
        context.push(ConductorRoutesPath.startTrips);
      case 2:
        context.push(ConductorRoutesPath.metrics);
      case 3:
        context.push(ConductorRoutesPath.vehicle);
    }
  }
}
