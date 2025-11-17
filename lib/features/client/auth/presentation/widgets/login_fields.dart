import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/features.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginFields extends StatelessWidget {
  const LoginFields({super.key, required this.isRegister});
  final bool isRegister;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        debugPrint('AuthState.password LoginFields= "${state.password}"');
        return Column(
          children: [
            CustomTextFormField(
              decoration: InputDecoration(
                hintText: 'Ingresa tu correo electrónico',
                labelText: 'Correo electrónico',
                border: InputBorder.none,
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: false,
              autocorrect: false,
              hasShowHidePassword: false,
              hasValidationRules: false,
              hasSpace: false,
              allowSpecialCharacters: true,
              hasStrengthIndicator: false,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  Helpers.getMessageFormValidation(state.isValidLoginEmail),
              onChanged: (value) =>
                  context.read<AuthBloc>().add(ChangeEmailEvent(email: value)),
            ),
            20.verticalSpace,
            CustomTextFormField(
              decoration: InputDecoration(
                hintText: 'Ingresa tu contraseña',
                labelText: 'Contraseña',
                border: InputBorder.none,
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autocorrect: false,
              hasShowHidePassword: true,
              hasValidationRules: isRegister ? true : false,
              hasStrengthIndicator: isRegister ? true : false,
              hasSpace: false,
              allowSpecialCharacters: true,
              textInputAction: TextInputAction.done,
              validator: (value) => isRegister
                  ? Helpers.getMessageFormValidation(state.isValidRegisterPsw)
                  : Helpers.getMessageFormValidation(state.isValidLoginPsw),
              onChanged: (value) =>
                  context.read<AuthBloc>().add(ChangePasswordEvent(psw: value)),
            ),
          ],
        );
      },
    );
  }
}
