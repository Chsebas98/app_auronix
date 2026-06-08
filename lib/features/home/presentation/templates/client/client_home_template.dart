import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/router/app_router.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/features/home/presentation/atoms/floating_button.dart';
import 'package:auronix_app/features/home/presentation/organisms/client/client_home_drawer.dart';
import 'package:auronix_app/features/home/presentation/organisms/client/client_home_feed.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientHomeTemplate extends StatelessWidget {
  const ClientHomeTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ClientTripBloc>(),
      child: Scaffold(
        backgroundColor: context.appColors.background,
        drawer: const ClientHomeDrawer(),
        body: Stack(
          children: [
            const ClientHomeFeed(),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: FloatingButton(
                label: 'Solicitar Taxi Ahora',
                onPressed: () =>
                    AppRouter.push(ClientRoutesPath.selectDestination),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
