import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/presentation/bloc/auth_form_cubit.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthPasswordField extends StatelessWidget {
  const AuthPasswordField({
    this.isRegister = false,
    this.label = 'Contraseña',
    this.hint = 'Ingresa tu contraseña',
    this.textInputAction = TextInputAction.done,
    super.key,
  });

  final bool isRegister;
  final String label;
  final String hint;
  final TextInputAction textInputAction;

  static Set<ValidationRule> _registerRules = {
    MinCharactersValidationRule(8),
    DigitValidationRule(),
    UppercaseValidationRule(),
    LowercaseValidationRule(),
    SpecialCharacterValidationRule(),
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthFormCubit, AuthFormState>(
      builder: (context, state) {
        return AppTextField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          autocorrect: false,
          hasShowHidePassword: true,
          hasValidationRules: isRegister,
          hasStrengthIndicator: isRegister,
          hasSpace: false,
          allowSpecialCharacters: true,
          textInputAction: textInputAction,
          validationRules: isRegister ? _registerRules : const {},
          decoration: InputDecoration(
            hintText: hint,
            labelText: label,
            border: InputBorder.none,
          ),
          // Login usa isValidLoginPsw, register usa isValidRegisterPsw
          validator: (_) => FormsHelpers.getMessageFormValidation(
            isRegister ? state.isValidRegisterPsw : state.isValidLoginPsw,
          ),
          onChanged: (v) => context.read<AuthFormCubit>().changePassword(v),
        );
      },
    );
  }
}
