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
          // Widget para el FAB, que se muestra sobre el feed y el drawer
        ],
      ),
    );
  }
}
