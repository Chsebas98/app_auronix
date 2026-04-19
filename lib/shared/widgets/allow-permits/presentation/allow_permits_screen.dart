import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class AllowPermitsScreen extends StatelessWidget {
  const AllowPermitsScreen({Key? key}) : super(key: key);

  Future<void> _requestPermission(BuildContext context) async {
    final theme = Theme.of(context);
    debugPrint('Solicitando permiso de ubicación...');

    final status = await Permission.locationWhenInUse.request();

    debugPrint('Resultado del permiso: $status');

    if (status.isGranted && context.mounted) {
      debugPrint('Permiso concedido → Navegando a home');
      // context.go(ClientRoutesPath.home);
    } else if (status.isDenied && context.mounted) {
      debugPrint('Permiso denegado');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Necesitamos el permiso para continuar',
            style: theme.textTheme.bodyLarge,
          ),
          backgroundColor: AppColors.tenth,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (status.isPermanentlyDenied && context.mounted) {
      debugPrint('Permiso permanentemente denegado');

      final shouldOpen = await context.read<DialogCubit>().showConfirm(
        title: 'Permiso requerido',
        message:
            'Has denegado el permiso de ubicación. Por favor, actívalo en la configuración de la app.',
        okText: 'Abrir configuración',
        cancelText: 'Cancelar',
      );

      if (shouldOpen && context.mounted) {
        debugPrint('Abriendo configuración...');
        await openAppSettings();

        // Opcional: Verificar de nuevo después de volver de settings
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (context.mounted) {
            final newStatus = await Permission.locationWhenInUse.status;
            if (newStatus.isGranted && context.mounted) {
              // context.go(ClientRoutesPath.home);
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.location_off_rounded,
                size: 120.sp,
                color: AppColors.tenth,
              ),
              32.verticalSpace,
              Text(
                'Necesitamos tu ubicación',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              16.verticalSpace,
              Text(
                'Para poder solicitar un taxi, necesitamos saber dónde estás.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              48.verticalSpace,
              FilledButton(
                onPressed: () => _requestPermission(context),
                child: Text(
                  'Permitir acceso a ubicación',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
