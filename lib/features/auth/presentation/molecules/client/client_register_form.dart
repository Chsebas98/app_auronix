import 'package:auronix_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_verify_request.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/presentation/atoms/auth_email_field.dart';
import 'package:auronix_app/features/auth/presentation/atoms/auth_password_field.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientRegisterForm extends StatelessWidget {
  const ClientRegisterForm({required this.formKey, super.key});

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: BlocBuilder<AuthFormCubit, AuthFormState>(
        builder: (context, state) {
          return Column(
            children: [
              const AuthEmailField(),
              20.verticalSpace,
              const AuthPasswordField(isRegister: true),
              12.verticalSpace,
              AppButton(
                label: 'Registrarse',
                expand: true,
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    context.read<AuthUnifiedBloc>().add(
                      AuthRegisterClientEvent(
                        verifyRequest: RegisterVerifyRequest(
                          email: state.email,
                          password: state.password,
                          rol: Roles.rolUser,
                        ),
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
