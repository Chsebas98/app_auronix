import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/router/driver/conductor_routes_path.dart';
import 'package:auronix_app/features/trips/presentation/bloc/driver-bloc/driver_trip_bloc.dart';
import 'package:auronix_app/features/trips/presentation/organisms/driver/driver_nearby_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DriverTripTemplate extends StatelessWidget {
  const DriverTripTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DriverTripBloc, DriverTripState>(
          listenWhen: (prev, curr) =>
              curr.status == DriverTripStatus.accepted &&
              prev.status != DriverTripStatus.accepted,
          listener: (context, state) =>
              context.push(ConductorRoutesPath.tripInProgress),
        ),
        BlocListener<DriverTripBloc, DriverTripState>(
          listenWhen: (prev, curr) =>
              curr.status == DriverTripStatus.error &&
              prev.status != DriverTripStatus.error,
          listener: (context, state) {
            context.read<DialogCubit>().hideAll();
            context.read<DialogCubit>().showMessage(
                  title: 'Error',
                  message: state.errorMessage ?? 'Ha ocurrido un error',
                );
          },
        ),
      ],
      child: const Scaffold(body: DriverNearbyMap()),
    );
  }
}
