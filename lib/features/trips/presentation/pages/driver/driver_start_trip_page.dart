import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/core/utils/helpers/jwt_helpers.dart';
import 'package:auronix_app/features/trips/presentation/bloc/driver-bloc/driver_trip_bloc.dart';
import 'package:auronix_app/features/trips/presentation/templates/driver/driver_trip_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverStartTripPage extends StatelessWidget {
  const DriverStartTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionBloc>().state;
    final userId = session is SessionAuthenticated
        ? JwtHelpers.getUserId(session.dataUser.tokenAccess) ?? 0
        : 0;

    return BlocProvider.value(
      value: sl<DriverTripBloc>()
        ..add(DriverTripLoadNearbyEvent(userId: userId))
        ..add(DriverTripConnectSocketEvent(driverId: userId)),
      child: const DriverTripTemplate(),
    );
  }
}
