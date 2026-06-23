import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/router/app_router.dart';
import 'package:auronix_app/app/router/driver/conductor_routes_path.dart';
import 'package:auronix_app/features/home/presentation/atoms/floating_button.dart';
import 'package:auronix_app/features/home/presentation/bloc/driver-bloc/home_driver_bloc.dart';
import 'package:auronix_app/features/home/presentation/organisms/driver/driver_home_drawer.dart';
import 'package:auronix_app/features/home/presentation/organisms/driver/driver_home_feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverHomeTemplate extends StatelessWidget {
  const DriverHomeTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeDriverBloc, HomeDriverState>(
      listenWhen: (prev, curr) =>
          curr.errorMessage != null &&
          curr.errorMessage != prev.errorMessage,
      listener: (context, state) {
        context.read<DialogCubit>().hideAll();
        context.read<DialogCubit>().showMessage(
              title: 'Error',
              message: state.errorMessage!,
            );
      },
      child: Scaffold(
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
                onPressed: () {
                  context.read<HomeDriverBloc>().add(
                        const HomeDriverToggleAvailabilityEvent(),
                      );
                  AppRouter.push(ConductorRoutesPath.startTrips);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
