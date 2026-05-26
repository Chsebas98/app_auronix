import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/features/trips/presentation/bloc/driver-bloc/driver_trip_bloc.dart';
import 'package:auronix_app/features/trips/presentation/templates/driver/driver_trip_completed_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverTripCompletedPage extends StatelessWidget {
  const DriverTripCompletedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<DriverTripBloc>(),
      child: const DriverTripCompletedTemplate(),
    );
  }
}
