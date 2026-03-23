import 'dart:async';

import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/domain/request/dialog_request.dart';
import 'package:auronix_app/core/core.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

part 'auth_conductor_event.dart';
part 'auth_conductor_state.dart';

class AuthConductorBloc extends Bloc<AuthConductorEvent, AuthConductorState> {
  final RxSharedPreferences _prefs;
  AuthConductorBloc(this._prefs) : super(AuthConductorState()) {
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
    final bool? saved = await _prefs.getBool(StaticVariables.rememberKey);
    if (saved != null) {
      emit(state.copyWith(isRemember: saved));
    }
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
    await _prefs.setBool(StaticVariables.rememberConductorKey, newValue);
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
    // debugPrint(event.psw);
    emit(state.copyWith(password: event.psw));
  }

  FutureOr<void> _onConductorRegisterSubmitEvent(
    ConductorRegisterSubmitEvent event,
    Emitter<AuthConductorState> emit,
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

  FutureOr<void> _onConductorLoginSubmittedEvent(
    ConductorLoginSubmittedEvent event,
    Emitter<AuthConductorState> emit,
  ) {}
}
