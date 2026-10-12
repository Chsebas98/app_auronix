import 'package:auronix_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_verify_request.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/presentation/atoms/auth_email_field.dart';
import 'package:auronix_app/features/auth/presentation/atoms/auth_password_field.dart';
import 'package:auronix_app/shared/atoms/buttons/app_icon_button.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/cupertino.dart';
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
              Row(
                children: [
                  Expanded(child: const AuthEmailField()),
                  8.horizontalSpace,
                  if (state.email.isNotEmpty)
                    AppIconButton(
                      iconAndroid: Icons.search,
                      iconIOS: CupertinoIcons.search,
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          context.read<AuthUnifiedBloc>().add(
                            AuthVerifyRegisterClientEvent(email: state.email),
                          );
                        }
                      },
                    ),
                ],
              ),
              20.verticalSpace,
              const AuthPasswordField(isRegister: true),
              12.verticalSpace,
              Row(
                children: [
                  Checkbox(
                    value: state.termsAccepted,
                    onChanged: (_) =>
                        context.read<AuthFormCubit>().toggleTerms(),
                  ),
                  Expanded(
                    child: Wrap(
                      children: [
                        Text('Acepto los '),
                        InkWell(
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Términos y Condiciones'),
                              content: const Text(
                                'Los términos y condiciones de Auronix se actualizarán antes del lanzamiento.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          ),
                          child: const Text(
                            'Términos y Condiciones',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              12.verticalSpace,
              AppButton(
                label: 'Registrarse',
                expand: true,
                onPressed: state.termsAccepted
                    ? () {
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
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
