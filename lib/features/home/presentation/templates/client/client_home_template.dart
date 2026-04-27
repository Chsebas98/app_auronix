import 'package:auronix_app/features/home/presentation/atoms/client_home_floating_button.dart';
import 'package:auronix_app/features/home/presentation/organisms/client/client_home_drawer.dart';
import 'package:auronix_app/features/home/presentation/organisms/client/client_home_feed.dart';
import 'package:flutter/material.dart';

/// Scaffold base del home cliente.
/// Solo estructura visual: drawer + body(feed + FAB flotante).
/// Sin logica de negocio.
class HomeClientTemplate extends StatelessWidget {
  const HomeClientTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      drawer: const ClientHomeDrawer(),
      body: const Stack(
        children: [
          ClientHomeFeed(),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ClientHomeFloatingButton(),
          ),
        ],
      ),
    );
  }
}
