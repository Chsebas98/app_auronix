import 'package:auronix_app/app/app.dart';
import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/core/bloc/domain/interfaces/dialog_presentation.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/router/client/client_routes_path.dart';
import 'package:auronix_app/app/router/driver/conductor_routes_path.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/core/models/interfaces/core_enums.dart';
import 'package:auronix_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auronix_app/features/auth/presentation/organisms/client/auth_client_body.dart';

import 'package:auronix_app/features/auth/presentation/organisms/driver/auth_driver_repository.dart';
import 'package:auronix_app/features/auth/presentation/pages/client/register_complete_page.dart';
import 'package:auronix_app/features/auth/presentation/templates/client/auth_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthUnifiedBloc>()),
        BlocProvider(
          create: (_) => sl<AuthFormCubit>()..initRemember(isDriver: false),
        ),
      ],
      child: const _AuthPageListener(),
    );
  }
}

class _AuthPageListener extends StatefulWidget {
  const _AuthPageListener();

  @override
  State<_AuthPageListener> createState() => _AuthPageListenerState();
}

class _AuthPageListenerState extends State<_AuthPageListener> {
  @override
  void dispose() {
    rootMessengerKey.currentState?.hideCurrentSnackBar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthUnifiedBloc, AuthUnifiedState>(
      listener: (context, state) {
        switch (state) {
          case AuthUnifiedLoading():
            rootMessengerKey.currentState?.hideCurrentSnackBar();
            context.read<DialogCubit>().showLoading();

          case AuthUnifiedFailure(:final failure):
            context.read<DialogCubit>().hideTop();
            context.read<DialogCubit>().showMessage(
              title: 'Error',
              message: failure.message,
            );

          case AuthUnifiedRegistering(:final email):
            // Delega todo al DialogHandler — el reemplaza el loading y abre el fullscreen
            context.read<DialogCubit>().showFullscreenDialog(
              presentation:
                  DialogPresentation.replaceTop, // cierra loading primero
              pageBuilder: (ctx) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<AuthUnifiedBloc>()),
                  BlocProvider.value(value: context.read<AuthFormCubit>()),
                ],
                child: RegisterCompletePage(email: email),
              ),
            );
          case AuthUnifiedVerified():
            context.read<DialogCubit>().showFullscreenDialog(
              presentation: DialogPresentation.replaceTop,
              pageBuilder: (ctx) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<AuthUnifiedBloc>()),
                  BlocProvider.value(value: context.read<AuthFormCubit>()),
                ],
                child: RegisterCompletePage(email: ''),
              ),
            );

          case AuthUnifiedIdle():
            context.read<DialogCubit>().hideTop();
          case AuthUnifiedSuccess():
            debugPrint('Login exitoso, navegar a home');

            switch (state.credentials.role) {
              case Roles.rolAdmin:
                throw UnimplementedError('Rol admin no implementado');
              case Roles.rolGerente:
                throw UnimplementedError('Rol gerente no implementado');
              case Roles.rolDriver:
                final driverCreds =
                    context.read<AuthUnifiedBloc>().state as AuthUnifiedSuccess;
                context.read<SessionBloc>().add(
                  LoginUserEvent(dataUser: driverCreds.credentials),
                );
                AppRouter.goAndClear(ConductorRoutesPath.home);
              case Roles.rolMember:
                throw UnimplementedError('Rol socio no implementado');
              case Roles.rolUser:
                AppRouter.goAndClear(ClientRoutesPath.home);
            }
        }
      },
      child: BlocBuilder<AuthFormCubit, AuthFormState>(
        builder: (context, formState) {
          return AuthTemplate(
            body: formState.showLoginConductorForm
                ? const AuthDriverBody()
                : const AuthClientBody(),
          );
        },
      ),
    );
  }
}
