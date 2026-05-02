import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/features/trips/presentation/bloc/driver-bloc/driver_trip_bloc.dart';
import 'package:auronix_app/features/trips/presentation/templates/driver/driver_trip_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverStartTripPage extends StatelessWidget {
  const DriverStartTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<DriverTripBloc>()..add(const DriverTripLoadNearbyEvent()),
      child: const DriverTripTemplate(),
    );
  }
}
