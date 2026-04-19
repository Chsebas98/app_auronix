import 'dart:async';
import 'package:auronix_app/features/features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
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
    debugPrint('Verificando sesión guardada...');
    emit(SessionLoading());

    final result = await _authRepository.getSavedSession();

    result.fold(
      (failure) {
        debugPrint('Error al verificar sesión: ${failure.message}');
        emit(SessionUnauthenticated());
      },
      (user) {
        if (user != null) {
          debugPrint('Sesión encontrada: ${user.username}');
          debugPrint('Email: ${user.email}');
          debugPrint('Rol: ${user.role}');
          emit(SessionAuthenticated(dataUser: user));
        } else {
          debugPrint('No hay sesión guardada');
          emit(SessionUnauthenticated());
        }
      },
    );
  }

  FutureOr<void> _onLoginUserEvent(
    LoginUserEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    try {
      final user = event.dataUser;
      return emit(SessionAuthenticated(dataUser: user));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  FutureOr<void> _onLoggoutUserEvent(
    LoggoutUserEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    await _authRepository.logout();
    emit(SessionUnauthenticated());
  }
}
