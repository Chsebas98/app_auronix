import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/presentation/bloc/auth_form_cubit.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCiField extends StatelessWidget {
  const AuthCiField({super.key});

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
          justUpperCase: true,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'Ingresa tu CI o Pasaporte',
            labelText: 'CI / Pasaporte',
            border: InputBorder.none,
          ),
          validator: (_) =>
              FormsHelpers.getMessageFormValidation(state.isValidCiPassport),
          onChanged: (v) => context.read<AuthFormCubit>().changeCiPassport(v),
        );
      },
    );
  }
}
