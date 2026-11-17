import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/features/home/presentation/bloc/driver-bloc/home_driver_bloc.dart';
import 'package:auronix_app/features/home/presentation/templates/driver/driver_home_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // userId: temporal hasta que el interceptor use JWT y extraiga el ID del token
      create: (_) => sl<HomeDriverBloc>()..add(const HomeDriverInitEvent(userId: 0)),
      child: const DriverHomeTemplate(),
    );
  }
}
