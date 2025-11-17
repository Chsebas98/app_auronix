import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/features.dart';
import 'package:auronix_app/shared/modals/modal_temp_cubit.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

GlobalKey<FormState> _registerClientFormKey = GlobalKey<FormState>();

class RegisterClientScreen extends StatelessWidget {
  const RegisterClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ModalTempCubit>(),
      child: _RegisterClientScreenStructure(),
    );
  }
}

class _RegisterClientScreenStructure extends StatelessWidget {
  const _RegisterClientScreenStructure();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog.fullscreen(
      backgroundColor: AppColors.white,
      child: BlocBuilder<ModalTempCubit, ModalTempState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppbarDefault(goTo: () => Navigator.pop(context)),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 24.w),
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Completar Registro'),
                ),
              ),
            ),
            body: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return Form(
                  key: _registerClientFormKey,
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    children: [
                      20.verticalSpace,
                      CustomTextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: false,
                        hasShowHidePassword: false,
                        hasValidationRules: false,
                        hasStrengthIndicator: false,
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu nombre',
                          labelText: 'Nombre',
                          border: InputBorder.none,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        textInputAction: TextInputAction.next,

                        validator: (value) {
                          final result = FormValidators.validateName(
                            value ?? '',
                          );
                          return result.isValid ? null : result.message;
                        },
                        onChanged: (value) => context
                            .read<ModalTempCubit>()
                            .stringTemp1ChangedEvent(value),
                      ),
                      20.verticalSpace,
                      CustomTextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: false,
                        hasShowHidePassword: false,
                        hasValidationRules: false,
                        hasStrengthIndicator: false,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          border: InputBorder.none,
                        ),
                        textInputAction: TextInputAction.next,
                        initialValue: state.email,
                      ),
                      20.verticalSpace,
                      CustomInputSelect(
                        label: 'Género',
                        options: ['Masculino', 'Femenino', 'Otro'],
                        validator: (value) => Helpers.getMessageFormValidation(
                          FormValidators.validateSelectOption(value ?? ''),
                        ),
                        onChanged: (value) => context
                            .read<ModalTempCubit>()
                            .stringTemp2ChangedEvent(value ?? 'Seleccionar'),
                      ),
                      20.verticalSpace,
                      CustomTextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: false,
                        hasShowHidePassword: false,
                        hasValidationRules: false,
                        hasStrengthIndicator: false,
                        decoration: InputDecoration(
                          labelText: 'Número de celular',
                          hintText: 'Ingresa tu número de celular',
                          border: InputBorder.none,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        textInputAction: TextInputAction.done,
                        validator: (value) => Helpers.getMessageFormValidation(
                          FormValidators.validatePhone(value ?? ''),
                        ),
                        onChanged: (value) => context
                            .read<ModalTempCubit>()
                            .stringTemp2ChangedEvent(value),
                      ),
                      20.verticalSpace,
                      CustomTextFormField(
                        obscureText: true,
                        hasShowHidePassword: true,
                        hasSpace: false,
                        allowSpecialCharacters: true,
                        hasStrengthIndicator:
                            context.read<ModalTempCubit>().state.boolTemp1
                            ? false
                            : true,
                        hasValidationRules:
                            context.read<ModalTempCubit>().state.boolTemp1
                            ? false
                            : true,
                        validationRules: {
                          MinCharactersValidationRule(8),
                          DigitValidationRule(),
                          UppercaseValidationRule(),
                          LowercaseValidationRule(),
                          SpecialCharacterValidationRule(),
                        },
                        decoration: InputDecoration(
                          labelText: 'Confirmar contraseña',
                          hintText: 'Confirma tu contraseña',
                          border: InputBorder.none,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        textInputAction: TextInputAction.done,
                        onChanged: (value) {
                          context
                              .read<ModalTempCubit>()
                              .stringTemp2ChangedEvent(value);
                          final isValid =
                              FormValidators.validateRegisterPassword(value);
                          context.read<ModalTempCubit>().boolTemp1ChangedEvent(
                            isValid.isValid,
                          );
                          final coincidePsw = value == state.password;
                          context.read<ModalTempCubit>().boolTemp2ChangedEvent(
                            coincidePsw,
                          );
                          if (context.read<ModalTempCubit>().state.boolTemp1) {
                            context
                                .read<ModalTempCubit>()
                                .boolTemp3ChangedEvent(true);
                          } else {
                            context
                                .read<ModalTempCubit>()
                                .boolTemp3ChangedEvent(false);
                          }
                        },
                      ),
                      if (context.read<ModalTempCubit>().state.boolTemp3)
                        10.verticalSpace,
                      if (context.read<ModalTempCubit>().state.boolTemp3)
                        Row(
                          children: [
                            Icon(
                              context.read<ModalTempCubit>().state.boolTemp2
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color:
                                  context.read<ModalTempCubit>().state.boolTemp2
                                  ? AppColors.fifth
                                  : AppColors.sevent,
                              size: 0.05.sw,
                            ),
                            Text(
                              'La contraseña ${context.read<ModalTempCubit>().state.boolTemp2 ? 'coincide' : 'no coincide'}',
                              maxLines: 1,
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color:
                                    context
                                        .read<ModalTempCubit>()
                                        .state
                                        .boolTemp2
                                    ? AppColors.fifth
                                    : AppColors.sevent,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
