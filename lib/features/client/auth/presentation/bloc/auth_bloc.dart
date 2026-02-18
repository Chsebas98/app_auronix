import 'dart:async';

import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/domain/request/dialog_request.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/client/auth/domain/models/request/register_request.dart';
import 'package:auronix_app/features/client/auth/domain/models/request/register_verify_request.dart';
import 'package:auronix_app/features/client/client.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final RxSharedPreferences _prefs = sl<RxSharedPreferences>();
  AuthBloc(this._authRepository) : super(AuthState()) {
    on<InitRememberEvent>(_onInitRememberEvent);
    on<ResetFormStateEvent>(_onResetFormStateEvent);
    on<GoogleSignInRequestedEvent>(_onGoogleSignInRequestedEvent);
    on<ShowRegisterFormEvent>(_onShowRegisterFormEvent);
    on<CheckedChangedEvent>(_onCheckedChangedEvent);
    on<ChangeEmailEvent>(_onChangeEmailEvent);
    on<ChangePasswordEvent>(_onChangePasswordEvent);
    on<RegisterSubmitEvent>(_onRegisterSubmitEvent);
    on<CompleteRegisterSubmitEvent>(_onCompleteRegisterSubmitEvent);
    on<LoginSubmittedEvent>(_onLoginSubmittedEvent);
  }

  FutureOr<void> _onInitRememberEvent(
    InitRememberEvent event,
    Emitter<AuthState> emit,
  ) async {
    final bool saved = await _authRepository.getRemember();
    emit(state.copyWith(isRemember: saved));
  }

  FutureOr<void> _onResetFormStateEvent(
    ResetFormStateEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(
      state.copyWith(
        loginForm: const InitialFormSubmitStatus(),
        registerForm: const InitialFormSubmitStatus(),
        completeRegisterForm: const InitialFormSubmitStatus(),
      ),
    );
  }

  FutureOr<void> _onGoogleSignInRequestedEvent(
    GoogleSignInRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(loginForm: FormSubmitProgress()));

      final creds = await _authRepository.loginWithGoogle();

      // debugPrint('Credenciales Google: ${creds.toString()}');
      // await Future.delayed(Duration(seconds: 10));
      if (creds.tokenAccess.isEmpty) {
        throw Exception('No se pudieron obtener las credenciales de Google');
      }
      final response = await _authRepository.loginOrRegisterWithGoogle(creds);

      if (!response.response) {
        throw ErrorServiceException(
          message: response.message,
          errorDetail: response.errorDetail,
          statusCode: response.statusCode,
        );
      }

      if (creds.photoUrl.isEmpty || creds.username.isEmpty) {
        _prefs.setBool(StaticVariables.needsProfileComplete, true);
        emit(
          state.copyWith(
            email: creds.email,
            password: creds.tokenAccess,
            credentialsLogin: creds,
            loginForm: FormSubmitSuccesfull(message: 'Faltan datos de perfil'),
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          email: creds.email,
          password: creds.tokenAccess,
          credentialsLogin: creds,
          loginForm: FormSubmitSuccesfull(
            message: 'Bienvenido ${creds.firstName}',
          ),
        ),
      );
    } on ErrorServiceException catch (e) {
      debugPrint('Error en Google Sign-In: ${e.message}');
      final errorMessage = DialogRequest(
        title: 'Error al iniciar sesión',
        description: e.message,
      );
      emit(
        state.copyWith(
          dialogRequest: errorMessage,
          loginForm: FormSubmitFailed(e.message),
        ),
      );
    } catch (e) {
      debugPrint('Error en Google Sign-In: $e');
      final errorMessage = DialogRequest(
        title: 'Error al iniciar sesión',
        description:
            'No podemos iniciar sesión con las credenciales proporcionadas.'
            'Por favor, verifica tu correo y contraseña e intenta nuevamente.',
      );
      emit(
        state.copyWith(
          dialogRequest: errorMessage,
          loginForm: FormSubmitFailed(e.toString()),
        ),
      );
    }
  }

  FutureOr<void> _onShowRegisterFormEvent(
    ShowRegisterFormEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(showRegisterForm: event.showRegister));
  }

  FutureOr<void> _onCheckedChangedEvent(
    CheckedChangedEvent event,
    Emitter<AuthState> emit,
  ) async {
    final newValue = !state.isRemember;
    await _authRepository.setRemember(newValue);
    emit(state.copyWith(isRemember: newValue));
  }

  FutureOr<void> _onChangeEmailEvent(
    ChangeEmailEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(email: event.email));
  }

  FutureOr<void> _onChangePasswordEvent(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) {
    // debugPrint(event.psw);
    emit(state.copyWith(password: event.psw));
  }

  FutureOr<void> _onRegisterSubmitEvent(
    RegisterSubmitEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(registerForm: FormSubmitProgress()));

      final registerData = RegisterVerifyRequest(
        email: event.email,
        password: event.psw,
        rol: event.rol,
      );

      final response = await _authRepository.verifyRegister(registerData);

      debugPrint('Register response: $response');
      //todo:verificar usuario
      if (!response.response) {
        throw ErrorServiceException(
          message: response.message,
          errorDetail: response.errorDetail,
          statusCode: response.statusCode,
        );
      }
      emit(
        state.copyWith(
          showRegisterCompleteForm: true,
          registerForm: FormSubmitSuccesfull(message: response.message),
        ),
      );
    } on ErrorServiceException catch (e) {
      debugPrint('Error en Registro: ${e.message}');
      final errorMessage = DialogRequest(
        title: 'Error al registrar usuario',
        description: e.message,
      );
      emit(
        state.copyWith(
          dialogRequest: errorMessage,
          completeRegisterForm: FormSubmitFailed(e.message),
          showRegisterCompleteForm: false,
        ),
      );
    } catch (e) {
      debugPrint('Error en Registro: $e');
      final errorMessage = DialogRequest(
        title: 'Error al registrar usuario',
        description:
            'No podemos registrar al usuario con las credenciales proporcionadas.'
            'Por favor, verifica tu correo y contraseña e intenta nuevamente.',
      );
      emit(
        state.copyWith(
          dialogRequest: errorMessage,
          completeRegisterForm: FormSubmitFailed(e.toString()),
          showRegisterCompleteForm: false,
        ),
      );
    }
  }

  FutureOr<void> _onCompleteRegisterSubmitEvent(
    CompleteRegisterSubmitEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(completeRegisterForm: FormSubmitProgress()));
      final registerData = RegisterRequest(
        email: event.email,
        password: event.psw,
        rol: event.rol,
        nombre1: event.name,
        username: '',
        ape1: '',
        ape2: '',
        nombre2: '',
      );

      debugPrint("Data que mando al repository: $registerData");
      final response = await _authRepository.registerUser(registerData);

      debugPrint('Complete Register response: $response');
      if (!response.response) {
        throw ErrorServiceException(
          message: response.message,
          errorDetail: response.errorDetail,
          statusCode: response.statusCode,
        );
      }

      emit(
        state.copyWith(
          showRegisterCompleteForm: false,
          completeRegisterForm: FormSubmitSuccesfull(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          completeRegisterForm: FormSubmitFailed(e.toString()),
          showRegisterCompleteForm: true,
        ),
      );
    }
  }

  FutureOr<void> _onLoginSubmittedEvent(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(loginForm: FormSubmitProgress()));

      // Validar email y password
      if (state.email.isEmpty || state.password.isEmpty) {
        throw Exception('Email y contraseña son requeridos');
      }

      // Llamar al repository
      final response = await _authRepository.login(
        email: state.email,
        password: state.password,
        rememberMe: state.isRemember,
      );

      if (!response.response) {
        throw ErrorServiceException(
          message: response.message,
          errorDetail: response.errorDetail,
          statusCode: response.statusCode,
        );
      }

      emit(
        state.copyWith(
          loginForm: FormSubmitSuccesfull(message: 'Inicio de sesión exitoso'),
        ),
      );
    } on ErrorServiceException catch (e) {
      debugPrint('Error en Google Sign-In: ${e.message}');
      final errorMessage = DialogRequest.fromResponse(
        statusCode: e.statusCode,
        message: e.message,
        errorDetail: e.errorDetail,
      );
      emit(
        state.copyWith(
          dialogRequest: errorMessage,
          loginForm: FormSubmitFailed(e.message),
        ),
      );
    } catch (e) {
      debugPrint('Error en login: $e');
      final errorMessage = DialogRequest(
        title: 'Error al iniciar sesión',
        description:
            'No podemos iniciar sesión con las credenciales proporcionadas. '
            'Por favor, verifica tu correo y contraseña e intenta nuevamente.',
      );
      emit(
        state.copyWith(
          dialogRequest: errorMessage,
          loginForm: FormSubmitFailed(
            e is ErrorServiceException ? e.message : 'Error al iniciar sesión',
          ),
        ),
      );
    }
  }
}
