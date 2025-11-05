import 'dart:async';

import 'package:auronix_app/app/core/bloc/forms-states/form_state_state.dart';
import 'package:auronix_app/core/core.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

part 'member_event.dart';
part 'member_state.dart';

class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final RxSharedPreferences _prefs;
  MemberBloc(this._prefs) : super(MemberState()) {
    on<MemberInitRememberEvent>(_onMemberInitRememberEvent);
    on<MemberShowRegisterFormEvent>(_onMemberShowRegisterFormEvent);
    on<MemberChangeCiPassportEvent>(_onMemberChangeCiPassportEvent);
    on<MemberChangePasswordEvent>(_onMemberChangePasswordEvent);
    on<MemberCheckedChangedEvent>(_onMemberCheckedChangedEvent);
    on<MemberRegisterSubmitEvent>(_onMemberRegisterSubmitEvent);
    on<MemberLoginSubmittedEvent>(_onMemberLoginSubmittedEvent);
  }

  FutureOr<void> _onMemberInitRememberEvent(
    MemberInitRememberEvent event,
    Emitter<MemberState> emit,
  ) async {
    final bool? saved = await _prefs.getBool(StaticVariables.rememberKey);
    if (saved != null) {
      emit(state.copyWith(isRemember: saved));
    }
  }

  FutureOr<void> _onMemberShowRegisterFormEvent(
    MemberShowRegisterFormEvent event,
    Emitter<MemberState> emit,
  ) {
    emit(state.copyWith(showRegisterForm: event.showRegister));
  }

  FutureOr<void> _onMemberCheckedChangedEvent(
    MemberCheckedChangedEvent event,
    Emitter<MemberState> emit,
  ) async {
    final newValue = !state.isRemember;
    await _prefs.setBool(StaticVariables.rememberKey, newValue);
    emit(state.copyWith(isRemember: newValue));
  }

  FutureOr<void> _onMemberChangeCiPassportEvent(
    MemberChangeCiPassportEvent event,
    Emitter<MemberState> emit,
  ) {
    emit(state.copyWith(ciPassport: event.ciPassport.toUpperCase()));
  }

  FutureOr<void> _onMemberChangePasswordEvent(
    MemberChangePasswordEvent event,
    Emitter<MemberState> emit,
  ) {
    debugPrint(event.psw);
    emit(state.copyWith(password: event.psw));
  }

  FutureOr<void> _onMemberRegisterSubmitEvent(
    MemberRegisterSubmitEvent event,
    Emitter<MemberState> emit,
  ) async {
    try {
      emit(state.copyWith(registerForm: FormSubmitProgress()));
      await Future.delayed(Duration(seconds: 3));
      final res = true;
      if (res) {
        emit(state.copyWith(registerForm: FormSubmitSuccesfull()));
      } else {
        emit(state.copyWith(registerForm: FormSubmitSuccesfull()));
      }
    } catch (e) {
      emit(state.copyWith(registerForm: FormSubmitFailed(e.toString())));
    }
  }

  FutureOr<void> _onMemberLoginSubmittedEvent(
    MemberLoginSubmittedEvent event,
    Emitter<MemberState> emit,
  ) {}
}
