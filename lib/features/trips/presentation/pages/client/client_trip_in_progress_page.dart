import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:auronix_app/features/trips/presentation/templates/client/client_trip_in_progress_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientTripInProgressPage extends StatelessWidget {
  const ClientTripInProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ClientTripBloc>(),
      child: const ClientTripInProgressTemplate(),
    );
  }
}
