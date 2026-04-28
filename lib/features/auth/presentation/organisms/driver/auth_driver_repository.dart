import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/app/design/theme/theme_extensions.dart';
import 'package:auronix_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auronix_app/features/auth/presentation/molecules/driver/driver_login_form.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final _driverFormKey = GlobalKey<FormState>();

class AuthDriverBody extends StatelessWidget {
  const AuthDriverBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        children: [
          const SizedBox(height: 20),

          const AppText(
            'Ingreso de Conductor',
            variant: AppTextVariant.headlineMedium,
            fontWeight: FontWeight.w600,
            align: TextAlign.center,
          ),

          const SizedBox(height: 10),

          const AppText(
            'Ingresa tus credenciales de conductor',
            variant: AppTextVariant.bodyMedium,
            align: TextAlign.center,
          ),

          const SizedBox(height: 40),

          DriverLoginForm(formKey: _driverFormKey),

          const SizedBox(height: 20),

          TextButton.icon(
            onPressed: () => context.read<AuthFormCubit>().hideDriverLogin(),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.twelveth,
              size: 18,
            ),
            label: AppText(
              'Volver a inicio de sesión cliente',
              variant: AppTextVariant.bodyMedium,
              color: context.appColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
