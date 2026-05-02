import 'package:auronix_app/app/router/app_router.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/features/home/presentation/atoms/floating_button.dart';
import 'package:auronix_app/features/home/presentation/organisms/client/client_home_drawer.dart';
import 'package:auronix_app/features/home/presentation/organisms/client/client_home_feed.dart';
import 'package:flutter/material.dart';

/// Scaffold base del home cliente.
/// Solo estructura visual: drawer + feed + FAB.
/// Sin logica de negocio ni BlocProvider.
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
            child: FloatingButton(
              label: 'Solicitar Taxi Ahora',
              onPressed: () =>
                  AppRouter.push(ClientRoutesPath.selectDestination),
            ),
          ),
        ],
      ),
    );
  }
}
