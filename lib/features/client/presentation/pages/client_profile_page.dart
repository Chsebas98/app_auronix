import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/features/client/presentation/bloc/client_profile_bloc.dart';
import 'package:auronix_app/features/client/presentation/templates/client_profile_template.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientProfilePage extends StatelessWidget {
  const ClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionBloc>().state;
    final userId = session is SessionAuthenticated
        ? (int.tryParse(session.dataUser.username) ?? 0)
        : 0;
    final credentials = session is SessionAuthenticated
        ? session.dataUser
        : const AuthenticationCredentials.empty();

    return BlocProvider(
      create: (_) => sl<ClientProfileBloc>()
        ..add(ClientProfileLoadEvent(userId: userId)),
      child: ClientProfileTemplate(initialCredentials: credentials),
    );
  }
}
