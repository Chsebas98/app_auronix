import 'dart:async';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final AuthUnifiedRepository _repository;
  final RxSharedPreferences _prefs;

  SessionBloc(this._repository, this._prefs) : super(const SessionInitial()) {
    on<CheckLoggedUserEvent>(_onCheckLoggedUser);
    on<LoginUserEvent>(_onLoginUser);
    on<LoggoutUserEvent>(_onLogout);
  }

  FutureOr<void> _onCheckLoggedUser(
    CheckLoggedUserEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());

    final lastRole = await _prefs.getString(StaticVariables.lastActiveRole);
    debugPrint('[Session] restoring session, lastActiveRole=$lastRole');

    if (lastRole == 'DRIVER') {
      final result = await _repository.getDriverSession();
      final creds = result.fold((_) => null, (c) => c);
      if (creds != null) {
        debugPrint('[Session] restored DRIVER session');
        emit(SessionAuthenticated(dataUser: creds));
        return;
      }
    }

    if (lastRole == 'CLIENT') {
      final result = await _repository.getClientSession();
      final creds = result.fold((_) => null, (c) => c);
      if (creds != null) {
        debugPrint('[Session] restored CLIENT session');
        emit(SessionAuthenticated(dataUser: creds));
        return;
      }
    }

    // Fallback si no hay lastRole guardado
    final clientResult = await _repository.getClientSession();
    final clientCreds = clientResult.fold((_) => null, (c) => c);
    if (clientCreds != null) {
      emit(SessionAuthenticated(dataUser: clientCreds));
      return;
    }

    final driverResult = await _repository.getDriverSession();
    final driverCreds = driverResult.fold((_) => null, (c) => c);
    if (driverCreds != null) {
      emit(SessionAuthenticated(dataUser: driverCreds));
      return;
    }

    emit(SessionUnauthenticated());
  }

  void _onLoginUser(
    LoginUserEvent event,
    Emitter<SessionState> emit,
  ) {
    emit(SessionAuthenticated(dataUser: event.dataUser));
  }

  FutureOr<void> _onLogout(
    LoggoutUserEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    await _repository.logout();
    emit(SessionUnauthenticated());
  }
}
