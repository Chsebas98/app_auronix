import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/home/presentation/bloc/driver-bloc/home_driver_bloc.dart';
import 'package:auronix_app/features/home/presentation/molecules/client/client_home_hero_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDriverBloc, HomeDriverState>(
      builder: (context, state) {
        final firstName = state.dataProfile.firstName.isNotEmpty
            ? FormsHelpers.getTextTransform(
                state.dataProfile.firstName,
                capitalize: true,
              )
            : 'Usuario';

        return ClientHomeHeroContent(
          firstName: firstName,
          address: state.currentAddress,
          isLoadingAddress: state.isLoadingAddress,
          onRefreshLocation: () =>
              context.read<HomeDriverBloc>().add(GetCurrentLocationEvent()),
        );
      },
    );
  }
}
