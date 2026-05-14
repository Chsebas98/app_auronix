import 'dart:async';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final AuthUnifiedRepository _repository;

  SessionBloc(this._repository) : super(const SessionInitial()) {
    on<CheckLoggedUserEvent>(_onCheckLoggedUser);
    on<LoginUserEvent>(_onLoginUser);
    on<LoggoutUserEvent>(_onLogout);
  }

  FutureOr<void> _onCheckLoggedUser(
    CheckLoggedUserEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());

    // Try client session first
    final clientResult = await _repository.getClientSession();
    final clientCreds = clientResult.fold((_) => null, (c) => c);
    if (clientCreds != null) {
      emit(SessionAuthenticated(dataUser: clientCreds));
      return;
    }

    // Try driver session
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
