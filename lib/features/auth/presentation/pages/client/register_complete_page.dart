import 'package:auronix_app/app/design/theme/app_colors.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterCompletePage extends StatefulWidget {
  const RegisterCompletePage({super.key, required this.email});
  final String email;

  @override
  State<RegisterCompletePage> createState() => _RegisterCompletePageState();
}

class _RegisterCompletePageState extends State<RegisterCompletePage> {
  final _formKey = GlobalKey<FormState>();

  // Estado local del formulario de completar registro
  String _name = '';
  String _gender = '';
  String _phone = '';
  String _confirmPassword = '';
  bool _passwordValid = false;
  bool _passwordMatch = false;
  bool _showMatchIndicator = false;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: AppColors.white,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppAppbar(
          hasBackButton: true,
          isCenter: true,
          content: AppText(
            'Completar Registro',
            variant: AppTextVariant.titleMedium,
          ),
          goTo: () => Navigator.pop(context),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: BlocBuilder<AuthFormCubit, AuthFormState>(
              builder: (context, formState) {
                return AppButton(
                  label: 'Completar Registro',
                  expand: true,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<AuthUnifiedBloc>().add(
                        // Nota: debes agregar AuthCompleteRegisterEvent
                        // con los campos name, email, gender, phone, password
                        // si aun no existe en auth_bloc_event.dart
                        AuthCompleteRegisterClientEvent(
                          name: _name,
                          email: formState.email,
                          gender: _gender,
                          phone: _phone,
                          password: _confirmPassword,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              20.verticalSpace,

              // Nombre
              AppTextField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: false,
                hasShowHidePassword: false,
                hasValidationRules: false,
                hasStrengthIndicator: false,
                hasSpace: true,
                justText: true,
                justUpperCase: true,
                maxLength: 80,
                decoration: const InputDecoration(
                  hintText: 'Ingresa tu nombre',
                  labelText: 'Nombre',
                  border: InputBorder.none,
                  counterText: '',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final r = FormValidators.validateName(v ?? '');
                  return r.isValid ? null : r.message;
                },
                onChanged: (v) => _name = v,
              ),

              20.verticalSpace,

              // Email de solo lectura
              BlocBuilder<AuthFormCubit, AuthFormState>(
                builder: (context, s) => AppTextField(
                  obscureText: false,
                  hasShowHidePassword: false,
                  hasValidationRules: false,
                  hasStrengthIndicator: false,
                  readOnly: true,
                  initialValue: s.email,
                  decoration: const InputDecoration(
                    labelText: 'Correo electronico',
                    border: InputBorder.none,
                  ),
                ),
              ),

              20.verticalSpace,

              // Genero
              AppInputSelect(
                label: 'Genero',
                options: const ['Masculino', 'Femenino', 'Otro'],
                validator: (v) => FormsHelpers.getMessageFormValidation(
                  FormValidators.validateSelectOption(v ?? ''),
                ),
                onChanged: (v) => _gender = v ?? '',
              ),

              20.verticalSpace,

              // Telefono
              AppTextField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: false,
                hasShowHidePassword: false,
                hasValidationRules: false,
                hasStrengthIndicator: false,
                justNumbers: true,
                maxLength: 10,
                decoration: const InputDecoration(
                  counterText: '',
                  labelText: 'Numero de celular',
                  hintText: 'Ingresa tu numero de celular',
                  border: InputBorder.none,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                textInputAction: TextInputAction.next,
                validator: (v) => FormsHelpers.getMessageFormValidation(
                  FormValidators.validatePhone(v ?? ''),
                ),
                onChanged: (v) => _phone = v,
              ),

              20.verticalSpace,

              // Confirmar contrasena
              BlocBuilder<AuthFormCubit, AuthFormState>(
                builder: (context, s) => AppTextField(
                  obscureText: true,
                  hasShowHidePassword: true,
                  hasSpace: false,
                  allowSpecialCharacters: true,
                  maxLength: 20,
                  hasStrengthIndicator: !_passwordValid,
                  hasValidationRules: !_passwordValid,
                  validationRules: !_passwordValid
                      ? {
                          MinCharactersValidationRule(8),
                          DigitValidationRule(),
                          UppercaseValidationRule(),
                          LowercaseValidationRule(),
                          SpecialCharacterValidationRule(),
                        }
                      : const {},
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contrasena',
                    hintText: 'Confirma tu contrasena',
                    counterText: '',
                    border: InputBorder.none,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  textInputAction: TextInputAction.done,
                  onChanged: (v) {
                    final result = FormValidators.validateRegisterPassword(v);
                    setState(() {
                      _confirmPassword = v;
                      _passwordValid = result.isValid;
                      _passwordMatch = v == s.password;
                      _showMatchIndicator = _passwordValid;
                    });
                  },
                ),
              ),

              // Indicador de coincidencia
              if (_showMatchIndicator) ...[
                10.verticalSpace,
                Row(
                  children: [
                    Icon(
                      _passwordMatch ? Icons.check_circle : Icons.cancel,
                      color: _passwordMatch
                          ? AppColors.fifth
                          : AppColors.sevent,
                      size: 20,
                    ),
                    6.horizontalSpace,
                    AppText(
                      _passwordMatch
                          ? 'La contrasena coincide'
                          : 'La contrasena no coincide',
                      variant: AppTextVariant.bodyMedium,
                      color: _passwordMatch
                          ? AppColors.fifth
                          : AppColors.sevent,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
