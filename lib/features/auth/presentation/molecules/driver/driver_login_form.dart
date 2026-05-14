import 'package:auronix_app/features/auth/presentation/atoms/auth_ci_field.dart';
import 'package:auronix_app/features/auth/presentation/atoms/auth_password_field.dart';
import 'package:auronix_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriverLoginForm extends StatelessWidget {
  const DriverLoginForm({required this.formKey, super.key});

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: BlocBuilder<AuthFormCubit, AuthFormState>(
        builder: (context, state) {
          return Column(
            children: [
              const AuthCiField(),
              20.verticalSpace,
              const AuthPasswordField(),
              8.verticalSpace,
              Align(
                alignment: Alignment.centerLeft,
                child: AppCheckbox(
                  value: state.isRemember,
                  onChanged: (_) => context
                      .read<AuthFormCubit>()
                      .toggleRemember(isDriver: true),
                  label: 'Recuérdame',
                ),
              ),
              12.verticalSpace,
              AppButton(
                label: 'Ingresar',
                expand: true,
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context.read<AuthUnifiedBloc>().add(
                      AuthLoginDriverEvent(
                        ciPassport: state.ciPassport,
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
