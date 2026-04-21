import 'package:auronix_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auronix_app/features/auth/presentation/atoms/auth_email_field.dart';
import 'package:auronix_app/features/auth/presentation/atoms/auth_password_field.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientLoginForm extends StatelessWidget {
  const ClientLoginForm({required this.formKey, super.key});

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: formKey,
      child: BlocBuilder<AuthFormCubit, AuthFormState>(
        builder: (context, state) {
          return Column(
            children: [
              const AuthEmailField(),
              20.verticalSpace,
              const AuthPasswordField(),
              8.verticalSpace,
              Row(
                children: [
                  AppCheckbox(
                    value: state.isRemember,
                    onChanged: (_) => context
                        .read<AuthFormCubit>()
                        .toggleRemember(isDriver: false),
                    label: 'Recuerdame',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: AppText(
                      'Olvidaste tu contrasena?',
                      variant: AppTextVariant.bodyMedium,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Iniciar sesion',
                expand: true,
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context.read<AuthUnifiedBloc>().add(
                      AuthLoginClientEvent(
                        email: state.email,
                        password: state.password,
                        rememberMe: state.isRemember,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
