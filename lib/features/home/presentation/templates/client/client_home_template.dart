import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/router/app_router.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/features/home/presentation/atoms/floating_button.dart';
import 'package:auronix_app/features/home/presentation/bloc/client-bloc/home_client_bloc.dart';
import 'package:auronix_app/features/home/presentation/organisms/client/client_home_drawer.dart';
import 'package:auronix_app/features/home/presentation/organisms/client/client_home_feed.dart';
import 'package:auronix_app/features/trips/negotiation/domain/models/address_suggestion.dart';
import 'package:auronix_app/features/trips/safety/presentation/bloc/emergency_contact_cubit.dart';
import 'package:auronix_app/features/trips/safety/presentation/pages/add_emergency_contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Scaffold base del home cliente.
/// Solo estructura visual: drawer + feed + FAB. El gate de contacto de
/// emergencia (docs/flow.md sección 11.1) vive en HomeClientBloc, no aquí.
class ClientHomeTemplate extends StatelessWidget {
  const ClientHomeTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      drawer: const ClientHomeDrawer(),
      body: Stack(
        children: [
          ClientHomeFeed(),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: BlocConsumer<HomeClientBloc, HomeClientState>(
              listenWhen: (prev, curr) =>
                  (curr.emergencyContactRequired &&
                      !prev.emergencyContactRequired) ||
                  curr.tripRequestNonce != prev.tripRequestNonce,
              listener: (context, state) async {
                if (state.tripRequestNonce > 0) {
                  final destination = await AppRouter.push<AddressSuggestion>(
                    ClientRoutesPath.selectDestination,
                  );
                  if (destination != null) {
                    AppRouter.push(
                      ClientRoutesPath.confirmTrip,
                      extra: destination,
                    );
                  }
                  return;
                }
                if (state.emergencyContactRequired) {
                  final clientBloc = context.read<HomeClientBloc>();
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
                    clientBloc.add(const HomeClientRequestTripEvent());
                  }
                }
              },
              builder: (context, state) {
                return FloatingButton(
                  label: 'Solicitar Taxi Ahora',
                  onPressed: () => context.read<HomeClientBloc>().add(
                    const HomeClientRequestTripEvent(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
