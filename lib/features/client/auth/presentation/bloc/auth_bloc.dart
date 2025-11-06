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
  ) {}

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
    debugPrint(event.psw);
    emit(state.copyWith(password: event.psw));
  }

  FutureOr<void> _onRegisterSubmitEvent(
    RegisterSubmitEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(registerForm: FormSubmitProgress()));
      await Future.delayed(Duration(seconds: 3));
      final res = true;
      if (res) {
        emit(state.copyWith(registerForm: FormSubmitSuccesfull()));
      }
      // else {
      //   emit(state.copyWith(registerForm: FormSubmitSuccesfull()));
      // }
    } catch (e) {
      emit(state.copyWith(registerForm: FormSubmitFailed(e.toString())));
    }
  }

  FutureOr<void> _onLoginSubmittedEvent(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) {}
}
