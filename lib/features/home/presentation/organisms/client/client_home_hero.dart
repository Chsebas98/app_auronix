import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/home/presentation/molecules/client/client_home_hero_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeClientHero extends StatefulWidget {
  const HomeClientHero({super.key});

  @override
  State<HomeClientHero> createState() => _HomeClientHeroState();
}

class _HomeClientHeroState extends State<HomeClientHero> {
  @override
  void initState() {
    super.initState();
    context.read<HomeClientBloc>().add(GetCurrentLocationEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeClientBloc, HomeClientState>(
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
              context.read<HomeClientBloc>().add(GetCurrentLocationEvent()),
        );
      },
    );
  }
}
