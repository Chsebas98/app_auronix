import 'dart:async';

import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/domain/request/dialog_request.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/client/client.dart';
import 'package:auronix_app/features/conductor/auth/domain/repository/auth_conductor_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'auth_conductor_event.dart';
part 'auth_conductor_state.dart';

class AuthConductorBloc
    extends Bloc<AuthConductorEvent, AuthConductorState> {
  final AuthConductorRepository _authConductorRepository;

  AuthConductorBloc(this._authConductorRepository)
      : super(AuthConductorState()) {
    on<ConductorInitRememberEvent>(_onConductorInitRememberEvent);
    on<ConductorResetFormStateEvent>(_onConductorResetFormStateEvent);
    on<ConductorShowRegisterFormEvent>(_onConductorShowRegisterFormEvent);
    on<ConductorChangeCiPassportEvent>(_onConductorChangeCiPassportEvent);
    on<ConductorChangePasswordEvent>(_onConductorChangePasswordEvent);
    on<ConductorCheckedChangedEvent>(_onConductorCheckedChangedEvent);
    on<ConductorRegisterSubmitEvent>(_onConductorRegisterSubmitEvent);
    on<ConductorLoginSubmittedEvent>(_onConductorLoginSubmittedEvent);
  }

  FutureOr<void> _onConductorInitRememberEvent(
    ConductorInitRememberEvent event,
    Emitter<AuthConductorState> emit,
  ) async {
    final bool saved = await _authConductorRepository.getRemember();
    emit(state.copyWith(isRemember: saved));
  }

  FutureOr<void> _onConductorResetFormStateEvent(
    ConductorResetFormStateEvent event,
    Emitter<AuthConductorState> emit,
  ) {
    emit(
      state.copyWith(
        loginForm: const InitialFormSubmitStatus(),
        registerForm: const InitialFormSubmitStatus(),
        dialogRequest: const DialogRequest.empty(),
        ciPassport: '',
        password: '',
      ),
    );
  }

  FutureOr<void> _onConductorShowRegisterFormEvent(
    ConductorShowRegisterFormEvent event,
    Emitter<AuthConductorState> emit,
  ) {
    emit(state.copyWith(showRegisterForm: event.showRegister));
  }

  FutureOr<void> _onConductorCheckedChangedEvent(
    ConductorCheckedChangedEvent event,
    Emitter<AuthConductorState> emit,
  ) async {
    final newValue = !state.isRemember;
    await _authConductorRepository.setRemember(newValue);
    emit(state.copyWith(isRemember: newValue));
  }

  FutureOr<void> _onConductorChangeCiPassportEvent(
    ConductorChangeCiPassportEvent event,
    Emitter<AuthConductorState> emit,
  ) {
    emit(state.copyWith(ciPassport: event.ciPassport.toUpperCase()));
  }

  FutureOr<void> _onConductorChangePasswordEvent(
    ConductorChangePasswordEvent event,
    Emitter<AuthConductorState> emit,
  ) {
    emit(state.copyWith(password: event.psw));
  }

  FutureOr<void> _onConductorRegisterSubmitEvent(
    ConductorRegisterSubmitEvent event,
    Emitter<AuthConductorState> emit,
  ) async {
    emit(state.copyWith(registerForm: FormSubmitProgress()));

    final result = await _authConductorRepository.register(
      ciPassport: event.ciPassport,
      password: event.psw,
      email: event.email,
    );

    result.fold(
      (failure) {
        debugPrint('Error en registro de conductor: ${failure.message}');
        emit(
          state.copyWith(
            dialogRequest: DialogRequest(
              title: 'Error al registrar',
              description: failure.message,
            ),
            registerForm: FormSubmitFailed(failure.message),
          ),
        );
      },
      (creds) {
        emit(
          state.copyWith(
            credentialsLogin: creds,
            registerForm: const FormSubmitSuccesfull(),
          ),
        );
      },
    );
  }

  FutureOr<void> _onConductorLoginSubmittedEvent(
    ConductorLoginSubmittedEvent event,
    Emitter<AuthConductorState> emit,
  ) async {
    emit(state.copyWith(loginForm: FormSubmitProgress()));

    debugPrint(
      'Login conductor con CI/Pasaporte: ${event.ciPassport}',
    );

    final result = await _authConductorRepository.login(
      ciPassport: event.ciPassport,
      password: event.psw,
      rememberMe: state.isRemember,
    );

    result.fold(
      (failure) {
        debugPrint('Error en login de conductor: ${failure.message}');
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
}
