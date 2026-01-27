import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/features.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MemberFields extends StatelessWidget {
  const MemberFields({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberBloc, MemberState>(
      builder: (context, state) {
        return Column(
          children: [
            CustomTextFormField(
              decoration: InputDecoration(
                hintText: 'Ingresa tu username',
                labelText: 'Username',
                border: InputBorder.none,
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: false,
              autocorrect: false,
              hasShowHidePassword: false,
              hasValidationRules: false,
              hasSpace: false,
              justUpperCase: true,
              allowSpecialCharacters: false,
              hasStrengthIndicator: false,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  FormsHelpers.getMessageFormValidation(state.isValidUsername),
              onChanged: (value) => context.read<MemberBloc>().add(
                MemberChangeCiPassportEvent(ciPassport: value.toUpperCase()),
              ),
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
              hasValidationRules: false,
              hasStrengthIndicator: false,
              hasSpace: false,
              allowSpecialCharacters: true,
              textInputAction: TextInputAction.done,
              validator: (value) =>
                  FormsHelpers.getMessageFormValidation(state.isValidLoginPsw),
              onChanged: (value) =>
                  context.read<AuthBloc>().add(ChangePasswordEvent(psw: value)),
            ),
          ],
        );
      },
    );
  }
}
