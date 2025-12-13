import 'dart:async';

import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/client/auth/infraestructure/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  AuthBloc(this._authRepository) : super(AuthState()) {
    on<InitRememberEvent>(_onInitRememberEvent);
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

  FutureOr<void> _onGoogleSignInRequestedEvent(
    GoogleSignInRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(loginForm: FormSubmitProgress()));

      final creds = await _authRepository.loginWithGoogle();

      debugPrint('Credenciales Google: ${creds.copyWith(token: '***')}');
      //todo: aqui es donde se debe llamar al login en el backend con las credenciales de google
    } catch (e) {
      debugPrint('Error en Google Sign-In: $e');
      emit(state.copyWith(loginForm: FormSubmitFailed(e.toString())));
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
      await Future.delayed(Duration(seconds: 1));
      final res = true;
      //todo:verificar usuario
      if (res) {
        emit(
          state.copyWith(
            registerForm: FormSubmitSuccesfull(),
            showRegisterCompleteForm: true,
          ),
        );
      }
      // else {
      //   emit(state.copyWith(registerForm: FormSubmitSuccesfull(),showRegisterCompleteForm: false));
      // }
    } catch (e) {
      emit(
        state.copyWith(
          registerForm: FormSubmitFailed(e.toString()),
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
      await Future.delayed(Duration(seconds: 1));
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
  ) {}
}
