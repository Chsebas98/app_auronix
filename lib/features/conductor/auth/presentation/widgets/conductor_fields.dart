import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/conductor/auth/presentation/bloc/auth_conductor_bloc.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConductorFields extends StatelessWidget {
  const ConductorFields({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthConductorBloc, AuthConductorState>(
      builder: (context, state) {
        return Column(
          children: [
            CustomTextFormField(
              decoration: InputDecoration(
                hintText: 'Ingresa tu cédula o pasaporte',
                labelText: 'Cédula/Pasaporte',
                border: InputBorder.none,
                counterText: '',
              ),
              maxLength: 20,
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
              onChanged: (value) => context.read<AuthConductorBloc>().add(
                ConductorChangeCiPassportEvent(ciPassport: value.toUpperCase()),
              ),
            ),
            20.verticalSpace,
            CustomTextFormField(
              decoration: InputDecoration(
                hintText: 'Ingresa tu contraseña',
                labelText: 'Contraseña',
                border: InputBorder.none,
                counterText: '',
              ),
              maxLength: 20,
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
              onChanged: (value) => context.read<AuthConductorBloc>().add(
                ConductorChangePasswordEvent(psw: value),
              ),
            ),
          ],
        );
      },
    );
  }
}
