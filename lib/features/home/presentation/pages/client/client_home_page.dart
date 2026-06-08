import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/home/presentation/bloc/client-bloc/home_client_bloc.dart';
import 'package:auronix_app/features/home/presentation/templates/client/client_home_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionState = context.read<SessionBloc>().state;
    final credentials = sessionState is SessionAuthenticated
        ? sessionState.dataUser
        : const AuthenticationCredentials.empty();

    return BlocProvider(
      create: (_) => sl<HomeClientBloc>()
        ..add(HomeClientInitEvent(credentials: credentials)),
      child: const ClientHomeTemplate(),
    );
  }
}
