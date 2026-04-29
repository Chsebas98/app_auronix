import 'package:auronix_app/app/app.dart';
import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
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
  bool _registerDialogOpen = false;

  @override
  void dispose() {
    rootMessengerKey.currentState?.hideCurrentSnackBar();
    super.dispose();
  }

  Future<void> _showRegisterComplete(BuildContext ctx) async {
    if (_registerDialogOpen) return;
    _registerDialogOpen = true;

    final authBloc = ctx.read<AuthUnifiedBloc>();
    final formCubit = ctx.read<AuthFormCubit>();

    await showGeneralDialog<void>(
      context: ctx,
      barrierDismissible: false,
      fullscreenDialog: true,
      useRootNavigator: false,
      pageBuilder: (_, __, ___) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: formCubit),
        ],
        child: const RegisterCompletePage(),
      ),
    );

    _registerDialogOpen = false;
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

          case AuthUnifiedVerified():
            // Verificacion OK — abrir dialogo de completar registro
            context.read<DialogCubit>().hideTop();
            _showRegisterComplete(context);

          case AuthUnifiedSuccess(:final credentials):
            context.read<DialogCubit>().hideTop();
            context.read<SessionBloc>().add(
              LoginUserEvent(dataUser: credentials),
            );

          case AuthUnifiedRegistering(:final email):
            context.read<DialogCubit>().hideTop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _showRegisterComplete(context);
            });

          case AuthUnifiedIdle():
            context.read<DialogCubit>().hideTop();
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
