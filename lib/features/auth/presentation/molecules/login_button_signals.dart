import 'package:auronix_app/features/auth/presentation/bloc/auth_bloc.dart';

/// T13-C1 T13-C3 T13-C4 T13-C6: el boton de login de cliente se deshabilita
/// si el email o la contraseña no cumplen el formato, o si ya hay un login
/// en curso (AuthUnifiedLoading).
bool isClientLoginDisabled(
  AuthFormState formState,
  AuthUnifiedState authState,
) =>
    !formState.isValidLoginEmail.isValid ||
    !formState.isValidLoginPsw.isValid ||
    isAuthLoginInProgress(authState);

/// Igual que [isClientLoginDisabled] pero para el formulario de conductor
/// (CI/pasaporte en vez de email).
bool isDriverLoginDisabled(
  AuthFormState formState,
  AuthUnifiedState authState,
) =>
    !formState.isValidCiPassport.isValid ||
    !formState.isValidLoginPsw.isValid ||
    isAuthLoginInProgress(authState);

bool isAuthLoginInProgress(AuthUnifiedState authState) =>
    authState is AuthUnifiedLoading;
