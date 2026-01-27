import 'dart:async';
import 'package:auronix_app/features/features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final AuthRepository _authRepository;
  SessionBloc(this._authRepository) : super(SessionInitial()) {
    on<CheckLoggedUserEvent>(_onCheckLoggedUserEvent);
    on<LoginUserEvent>(_onLoginUserEvent);
    on<LoggoutUserEvent>(_onLoggoutUserEvent);
  }

  FutureOr<void> _onCheckLoggedUserEvent(
    CheckLoggedUserEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    final response = await _authRepository.getSavedSession();
    if (response != null) {
      emit(SessionAuthenticated(dataUser: response));
    } else {
      emit(SessionUnauthenticated());
    }
  }

  FutureOr<void> _onLoginUserEvent(
    LoginUserEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    try {
      final response = await _authRepository.login(
        email: event.email,
        password: event.password,
        isGoogle: event.isGoogle,
      );
      emit(SessionAuthenticated(dataUser: response));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  FutureOr<void> _onLoggoutUserEvent(
    LoggoutUserEvent event,
    Emitter<SessionState> emit,
  ) async {
    await _authRepository.logout();
    emit(SessionUnauthenticated());
  }
}
