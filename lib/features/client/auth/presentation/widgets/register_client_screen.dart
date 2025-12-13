import 'package:auronix_app/app/core/bloc/session-bloc/session_bloc.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/theme/theme.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/features.dart';
import 'package:auronix_app/shared/modals/modal_temp_cubit.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterClientScreen extends StatelessWidget {
  const RegisterClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<ModalTempCubit>()),
        BlocProvider(create: (context) => sl<SessionBloc>()),
      ],
      child: _RegisterClientScreenStructure(),
    );
  }
}

class _RegisterClientScreenStructure extends StatefulWidget {
  const _RegisterClientScreenStructure();

  @override
  State<_RegisterClientScreenStructure> createState() =>
      _RegisterClientScreenStructureState();
}

class _RegisterClientScreenStructureState
    extends State<_RegisterClientScreenStructure> {
  final GlobalKey<FormState> _registerClientFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog.fullscreen(
      backgroundColor: AppColors.white,
      child: BlocBuilder<ModalTempCubit, ModalTempState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppbarDefault(
              isCenter: true,
              content: Text(
                'Completar Registro',
                style: theme.textTheme.titleMedium,
              ),
              goTo: () => Navigator.pop(context),
            ),
            bottomNavigationBar: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 24.w),
                    child: FilledButton(
                      onPressed: () {
                        if (_registerClientFormKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            CompleteRegisterSubmitEvent(
                              name: state.stringTemp1,
                              email: authState.email,
                              gender: state.stringTemp2,
                              psw: state.stringTemp3,
                            ),
                          );

                          Navigator.pop(context);
                        }
                      },
                      child: Text('Completar Registro'),
                    ),
                  ),
                );
              },
            ),
            body: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
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
                        hasSpace: true,
                        justText: true,
                        justUpperCase: true,
                        maxLength: 80,
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
                        initialValue: authState.email,
                      ),
                      20.verticalSpace,
                      CustomInputSelect(
                        label: 'Género',
                        options: ['Masculino', 'Femenino', 'Otro'],
                        validator: (value) =>
                            FormsHelpers.getMessageFormValidation(
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
                        justNumbers: true,
                        maxLength: 10,
                        decoration: InputDecoration(
                          labelText: 'Número de celular',
                          hintText: 'Ingresa tu número de celular',
                          border: InputBorder.none,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        textInputAction: TextInputAction.done,
                        validator: (value) =>
                            FormsHelpers.getMessageFormValidation(
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
                        maxLength: 20,
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
                          final coincidePsw = value == authState.password;
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
