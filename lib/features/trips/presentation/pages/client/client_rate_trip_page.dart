import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:auronix_app/features/trips/presentation/templates/client/client_rate_trip_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientRateTripPage extends StatelessWidget {
  const ClientRateTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ClientTripBloc>(),
      child: const ClientRateTripTemplate(),
    );
  }
}
