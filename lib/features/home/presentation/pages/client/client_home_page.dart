import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/features/home/presentation/bloc/client/home_client_bloc.dart';
import 'package:auronix_app/features/home/presentation/templates/client/client_home_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeClientBloc>()..add(const HomeClientInitEvent()),
      child: const ClientHomeTemplate(),
    );
  }
}
