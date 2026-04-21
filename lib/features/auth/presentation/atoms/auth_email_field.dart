import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/presentation/bloc/auth_form_cubit.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthEmailField extends StatelessWidget {
  const AuthEmailField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthFormCubit, AuthFormState>(
      builder: (context, state) {
        return AppTextField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: false,
          autocorrect: false,
          hasShowHidePassword: false,
          hasValidationRules: false,
          hasStrengthIndicator: false,
          hasSpace: false,
          allowSpecialCharacters: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'Ingresa tu correo electronico',
            labelText: 'Correo electronico',
            border: InputBorder.none,
          ),
          // Lee el getter directamente del state
          validator: (_) =>
              FormsHelpers.getMessageFormValidation(state.isValidLoginEmail),
          onChanged: (v) => context.read<AuthFormCubit>().changeEmail(v),
        );
      },
    );
  }
}
