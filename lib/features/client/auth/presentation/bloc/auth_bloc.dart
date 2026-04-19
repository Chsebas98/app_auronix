import 'dart:async';

import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/domain/request/dialog_request.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/client/client.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final RxSharedPreferences _prefs;

  AuthBloc(this._authRepository, {required RxSharedPreferences prefs})
    : _prefs = prefs,
      super(AuthState()) {
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
    on<ConductorSignInRequestedEvent>(_onConductorSignInRequestedEvent);
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
    emit(state.copyWith(loginForm: FormSubmitProgress()));

    final googleResult = await _authRepository.loginWithGoogle();

    final googleFailure = googleResult.fold<Failure?>((f) => f, (_) => null);
    if (googleFailure != null) {
      debugPrint(
        'Error obteniendo credenciales Google: ${googleFailure.message}',
      );
      emit(
        state.copyWith(
          dialogRequest: DialogRequest(
            title: 'Error al iniciar sesión',
            description: googleFailure.message,
          ),
          loginForm: FormSubmitFailed(googleFailure.message),
        ),
      );
      return;
    }

    final creds = googleResult.getOrElse(
      () => const AuthenticationCredentials.empty(),
    );

    if (creds.tokenAccess.isEmpty) {
      emit(
        state.copyWith(
          loginForm: const FormSubmitFailed(
            'No se pudieron obtener las credenciales de Google',
          ),
        ),
      );
      return;
    }

    final result = await _authRepository.loginOrRegisterWithGoogle(creds);

    result.fold(
      (failure) {
        debugPrint('Error en Google Sign-In: ${failure.message}');
        emit(
          state.copyWith(
            dialogRequest: DialogRequest(
              title: 'Error al iniciar sesión',
              description: failure.message,
            ),
            loginForm: FormSubmitFailed(failure.message),
          ),
        );
      },
      (updatedCreds) {
        if (updatedCreds.photoUrl.isEmpty || updatedCreds.username.isEmpty) {
          _prefs.setBool(StaticVariables.needsProfileComplete, true);
          emit(
            state.copyWith(
              email: updatedCreds.email,
              password: updatedCreds.tokenAccess,
              credentialsLogin: updatedCreds,
              loginForm: const FormSubmitSuccesfull(
                message: 'Faltan datos de perfil',
              ),
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            email: updatedCreds.email,
            password: updatedCreds.tokenAccess,
            credentialsLogin: updatedCreds,
            loginForm: FormSubmitSuccesfull(
              message: 'Bienvenido ${updatedCreds.firstName}',
            ),
          ),
        );
      },
    );
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
    emit(state.copyWith(password: event.psw));
  }

  FutureOr<void> _onRegisterSubmitEvent(
    RegisterSubmitEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(registerForm: FormSubmitProgress()));

    final registerData = RegisterVerifyRequest(
      email: event.email,
      password: event.psw,
      rol: event.rol,
    );

    final result = await _authRepository.verifyRegister(registerData);

    result.fold(
      (failure) {
        debugPrint('Error en Registro: ${failure.message}');
        emit(
          state.copyWith(
            dialogRequest: DialogRequest(
              title: 'Error al registrar usuario',
              description: failure.message,
            ),
            completeRegisterForm: FormSubmitFailed(failure.message),
            showRegisterCompleteForm: false,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            showRegisterCompleteForm: true,
            registerForm: const FormSubmitSuccesfull(),
          ),
        );
      },
    );
  }

  FutureOr<void> _onCompleteRegisterSubmitEvent(
    CompleteRegisterSubmitEvent event,
    Emitter<AuthState> emit,
  ) async {
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
    final result = await _authRepository.registerUser(registerData);

    result.fold(
      (failure) {
        debugPrint('Error en CompleteRegister: ${failure.message}');
        emit(
          state.copyWith(
            completeRegisterForm: FormSubmitFailed(failure.message),
            showRegisterCompleteForm: true,
          ),
        );
      },
      (creds) {
        emit(
          state.copyWith(
            credentialsLogin: creds,
            showRegisterCompleteForm: false,
            completeRegisterForm: const FormSubmitSuccesfull(),
          ),
        );
      },
    );
  }

  FutureOr<void> _onLoginSubmittedEvent(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(loginForm: FormSubmitProgress()));

    if (state.email.isEmpty || state.password.isEmpty) {
      emit(
        state.copyWith(
          loginForm: const FormSubmitFailed(
            'Email y contraseña son requeridos',
          ),
        ),
      );
      return;
    }

    final result = await _authRepository.login(
      email: state.email,
      password: state.password,
      rememberMe: state.isRemember,
    );

    result.fold(
      (failure) {
        debugPrint('Error en login: ${failure.message}');
        emit(
          state.copyWith(
            dialogRequest: DialogRequest.fromResponse(
              statusCode: failure.statusCode,
              message: failure.message,
              errorDetail: failure.detail,
            ),
            loginForm: FormSubmitFailed(failure.message),
          ),
        );
      },
      (creds) {
        emit(
          state.copyWith(
            credentialsLogin: creds,
            loginForm: const FormSubmitSuccesfull(
              message: 'Inicio de sesión exitoso',
            ),
          ),
        );
      },
    );
  }

  FutureOr<void> _onConductorSignInRequestedEvent(
    ConductorSignInRequestedEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(showLoginConductorForm: !state.showLoginConductorForm));
  }
}
