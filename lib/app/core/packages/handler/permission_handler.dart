import 'package:auronix_app/app/app.dart';
import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler extends StatelessWidget {
  const PermissionHandler({
    super.key,
    required this.child,
    this.isDefaultSnackbar,
    this.typeColor,
    this.textButton,
  });

  final TypeToast? isDefaultSnackbar;
  final TypeColor? typeColor;
  final String? textButton;
  final Widget child;

  void _showGoToSettingsSnackbar(BuildContext ctx) {
    final theme = Theme.of(ctx);
    rootMessengerKey.currentState?.showSnackBar(
      CustomSnackbar(
        theme: theme,
        seconds: 5,
        title: 'Se necesita la ubicación',
        description: 'Debes habilitar los permisos de ubicación desde Ajustes.',
        isDefaultSnackbar: isDefaultSnackbar ?? TypeToast.actionToast,
        typeColor: typeColor ?? TypeColor.warning,
        behavior: SnackBarBehavior.floating,
        textButton: textButton ?? 'Ir a configuración',
        actionClosed: () {
          ctx.read<PermissionCubit>().openSettings();
          rootMessengerKey.currentState?.hideCurrentSnackBar();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = sl<PermissionCubit>();
        cubit.checkPermissions();
        return cubit;
      },
      child: BlocListener<PermissionCubit, PermissionState>(
        listenWhen: (previous, current) =>
            previous.ubicacion != current.ubicacion ||
            previous.ubicacionWhenInUse != current.ubicacionWhenInUse,
        // || previous.ubicacionAlways != current.ubicacionAlways,
        listener: (context, state) async {
          final permanentlyDenied =
              state.ubicacion == PermissionStatus.permanentlyDenied ||
              state.ubicacionWhenInUse == PermissionStatus.permanentlyDenied;
          // ||state.ubicacionAlways == PermissionStatus.permanentlyDenied;
          if (permanentlyDenied) {
            _showGoToSettingsSnackbar(context);
            await Future.delayed(Duration(seconds: 6));
            AppRouter.go(Routes.allowLocation);
          }
        },
        child: child,
      ),
    );
  }
}
