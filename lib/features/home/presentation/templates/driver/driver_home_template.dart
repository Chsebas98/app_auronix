import 'package:auronix_app/app/router/app_router.dart';
import 'package:auronix_app/app/router/driver/conductor_routes_path.dart';
import 'package:auronix_app/features/home/presentation/atoms/floating_button.dart';
import 'package:auronix_app/features/home/presentation/organisms/driver/driver_home_drawer.dart';
import 'package:auronix_app/features/home/presentation/organisms/driver/driver_home_feed.dart';
import 'package:flutter/material.dart';

/// Scaffold base del home driver.
/// Solo estructura visual: drawer + feed + FAB.
/// Sin logica de negocio ni BlocProvider.
class DriverHomeTemplate extends StatelessWidget {
  const DriverHomeTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      drawer: const DriverHomeDrawer(),
      body: Stack(
        children: [
          DriverHomeFeed(),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: FloatingButton(
              label: 'Iniciar Turno',
              onPressed: () => AppRouter.push(ConductorRoutesPath.startTrips),
            ),
          ),
          // Widget para el FAB, que se muestra sobre el feed y el drawer
        ],
      ),
    );
  }
}
