import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/home/presentation/bloc/driver-bloc/home_driver_bloc.dart';
import 'package:auronix_app/features/home/presentation/molecules/driver/driver_home_hero_content.dart';
import 'package:auronix_app/features/trips/safety/presentation/bloc/emergency_contact_cubit.dart';
import 'package:auronix_app/features/trips/safety/presentation/pages/add_emergency_contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

class DriverHomeHero extends StatefulWidget {
  const DriverHomeHero({super.key});

  @override
  State<DriverHomeHero> createState() => _DriverHomeHeroState();
}

class _DriverHomeHeroState extends State<DriverHomeHero> {
  @override
  void initState() {
    super.initState();
    context.read<HomeDriverBloc>().add(GetCurrentLocationEvent());
  }

  void _onToggleAvailability(BuildContext context) {
    context.read<HomeDriverBloc>().add(
      const HomeDriverToggleAvailabilityEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeDriverBloc, HomeDriverState>(
      listenWhen: (prev, curr) =>
          (curr.gpsRequired && !prev.gpsRequired) ||
          (curr.emergencyContactRequired && !prev.emergencyContactRequired),
      listener: (context, state) async {
        if (state.gpsRequired) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Debes activar el GPS para ponerte disponible',
              ),
              action: SnackBarAction(
                label: 'Ir a Ajustes',
                onPressed: () => Geolocator.openLocationSettings(),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
          return;
        }

        if (state.emergencyContactRequired) {
          final driverBloc = context.read<HomeDriverBloc>();
          final saved = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => sl<EmergencyContactCubit>(),
                child: const AddEmergencyContactPage(),
              ),
            ),
          );
          if (saved == true) {
            driverBloc.add(const HomeDriverToggleAvailabilityEvent());
          }
        }
      },
      builder: (context, state) {
        final firstName = state.dataProfile.firstName.isNotEmpty
            ? FormsHelpers.getTextTransform(
                state.dataProfile.firstName,
                capitalize: true,
              )
            : 'Usuario';

        return DriverHomeHeroContent(
          firstName: firstName,
          address: state.currentAddress,
          isLoadingAddress: state.isLoadingAddress,
          isAvailable: state.isAvailable,
          onRefreshLocation: () =>
              context.read<HomeDriverBloc>().add(GetCurrentLocationEvent()),
          onToggleAvailability: () => _onToggleAvailability(context),
        );
      },
    );
  }
}
