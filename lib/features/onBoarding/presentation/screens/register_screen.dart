import 'package:auronix_app/app/core/bloc/session-bloc/session_bloc.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/router/router.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/data/models/register_request_model.dart';
import 'package:auronix_app/features/auth/domain/models/user_role.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auronix_app/features/auth/presentation/widgets/role_selector.dart';
import 'package:auronix_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Registro de cuenta (T14): datos personales + seleccion explicita de rol,
/// y cooperativa cuando el rol es conductor. Llama al backend real
/// (AuthUnifiedRepository.registerWithBackend, T11), que ya encadena un
/// login automatico (T14-C6) y persiste el JWT en SecureStorageService.
///
/// Pantalla nueva y separada del wizard de 3 pasos existente
/// (ClientRegisterForm + RegisterCompletePage), que habla un contrato de
/// backend distinto (verify-register) que no existe en el backend real
/// (ver docs/architecture/existing_foundation.md). No se toca ese wizard.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String _firstName = '';
  String _lastName = '';
  String _cedula = '';
  String _email = '';
  String _password = '';
  String _cooperativaId = '';
  UserRole? _role;

  bool _submitting = false;
  String? _errorMessage;

  bool get _isFormValid {
    if (_role == null) return false;
    if (!FormValidators.validateName(_firstName.trim()).isValid) return false;
    if (!FormValidators.validateName(_lastName.trim()).isValid) return false;
    if (!FormValidators.validateCiPassport(_cedula.trim()).isValid) {
      return false;
    }
    if (!FormValidators.validateLoginEmail(_email.trim()).isValid) {
      return false;
    }
    if (!FormValidators.validateRegisterPassword(_password).isValid) {
      return false;
    }
    if (_role == UserRole.conductor && _cooperativaId.trim().isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;
    if (!_isFormValid) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final repository = sl<AuthUnifiedRepository>();
    final result = await repository.registerWithBackend(
      RegisterRequestModel(
        email: _email.trim(),
        password: _password,
        firstName: _firstName.trim(),
        lastName: _lastName.trim(),
        cedula: _cedula.trim(),
        role: _role!,
        cooperativaId: _role == UserRole.conductor
            ? int.tryParse(_cooperativaId.trim())
            : null,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _submitting = false;
          _errorMessage = failure.message;
        });
      },
      (_) {
        // T14-C6: el registro ya dejo el JWT en SecureStorageService —
        // SessionBloc lo recoge (T12) y el router redirige segun el rol.
        context.read<SessionBloc>().add(const CheckLoggedUserEvent());
        context.go(Routes.onBoarding);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(
        hasBackButton: true,
        isCenter: true,
        content: const AppText(
          'Crear cuenta',
          variant: AppTextVariant.titleMedium,
        ),
        goTo: () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              20.verticalSpace,
              AppText(
                '¿Cómo vas a usar Ando?',
                variant: AppTextVariant.bodyMedium,
              ),
              12.verticalSpace,
              RoleSelector(
                selected: _role,
                onChanged: (role) => setState(() => _role = role),
              ),
              if (_role == null) ...[
                6.verticalSpace,
                AppText(
                  'Selecciona un rol para continuar',
                  variant: AppTextVariant.bodySmall,
                  color: Colors.red,
                ),
              ],
              20.verticalSpace,
              AppTextField(
                key: const Key('register_firstName'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                hasShowHidePassword: false,
                hasValidationRules: false,
                hasStrengthIndicator: false,
                hasSpace: true,
                justText: true,
                allowTildes: true,
                decoration: const InputDecoration(
                  labelText: 'Nombres',
                  hintText: 'Ingresa tus nombres',
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final r = FormValidators.validateName((v ?? '').trim());
                  return FormsHelpers.getMessageFormValidation(r);
                },
                onChanged: (v) => setState(() => _firstName = v),
              ),
              16.verticalSpace,
              AppTextField(
                key: const Key('register_lastName'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                hasShowHidePassword: false,
                hasValidationRules: false,
                hasStrengthIndicator: false,
                hasSpace: true,
                justText: true,
                allowTildes: true,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  hintText: 'Ingresa tus apellidos',
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final r = FormValidators.validateName((v ?? '').trim());
                  return FormsHelpers.getMessageFormValidation(r);
                },
                onChanged: (v) => setState(() => _lastName = v),
              ),
              16.verticalSpace,
              AppTextField(
                key: const Key('register_cedula'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                hasShowHidePassword: false,
                hasValidationRules: false,
                hasStrengthIndicator: false,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cédula / Pasaporte',
                  hintText: 'Ingresa tu cédula o pasaporte',
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final r = FormValidators.validateCiPassport((v ?? '').trim());
                  return FormsHelpers.getMessageFormValidation(r);
                },
                onChanged: (v) => setState(() => _cedula = v),
              ),
              if (_role == UserRole.conductor) ...[
                16.verticalSpace,
                AppTextField(
                  key: const Key('register_cooperativa'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  hasShowHidePassword: false,
                  hasValidationRules: false,
                  hasStrengthIndicator: false,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cooperativa (ID)',
                    hintText: 'Identificador de tu cooperativa',
                    border: InputBorder.none,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'La cooperativa es obligatoria para conductores'
                      : null,
                  onChanged: (v) => setState(() => _cooperativaId = v),
                ),
              ],
              16.verticalSpace,
              AppTextField(
                key: const Key('register_email'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                hasShowHidePassword: false,
                hasValidationRules: false,
                hasStrengthIndicator: false,
                allowSpecialCharacters: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'Ingresa tu correo electrónico',
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final r = FormValidators.validateLoginEmail((v ?? '').trim());
                  return FormsHelpers.getMessageFormValidation(r);
                },
                onChanged: (v) => setState(() => _email = v),
              ),
              16.verticalSpace,
              AppTextField(
                key: const Key('register_password'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                hasShowHidePassword: true,
                hasValidationRules: true,
                hasStrengthIndicator: true,
                hasSpace: false,
                allowSpecialCharacters: true,
                validationRules: {
                  MinCharactersValidationRule(8),
                  DigitValidationRule(),
                  UppercaseValidationRule(),
                  LowercaseValidationRule(),
                  SpecialCharacterValidationRule(),
                },
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Crea una contraseña',
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.done,
                validator: (v) {
                  final r = FormValidators.validateRegisterPassword(v ?? '');
                  return FormsHelpers.getMessageFormValidation(r);
                },
                onChanged: (v) => setState(() => _password = v),
              ),
              if (_errorMessage != null) ...[
                12.verticalSpace,
                AppText(
                  _errorMessage!,
                  variant: AppTextVariant.bodyMedium,
                  color: Colors.red,
                ),
              ],
              24.verticalSpace,
              AppButton(
                label: 'Crear cuenta',
                expand: true,
                isDisabled: !_isFormValid,
                isLoading: _submitting,
                onPressed: _submit,
              ),
              24.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
