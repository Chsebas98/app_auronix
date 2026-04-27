import 'package:flutter/material.dart';

/// Scaffold base del home conductor.
class DriverHomeTemplate extends StatelessWidget {
  const DriverHomeTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      // drawer: const DriverHomeDrawer(),
      // body: const DriverHomeFeed(),
      body: Container(
        color: Colors.white,
        child: const Center(child: Text('Driver Home Feed')),
      ),
    );
  }
}
