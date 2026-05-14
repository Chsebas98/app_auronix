import 'package:auronix_app/features/trips/presentation/organisms/driver/driver_nearby_map.dart';
import 'package:flutter/material.dart';

class DriverTripTemplate extends StatelessWidget {
  const DriverTripTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: DriverNearbyMap());
  }
}
