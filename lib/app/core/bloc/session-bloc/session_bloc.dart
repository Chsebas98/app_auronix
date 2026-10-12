import 'dart:async';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auronix_app/features/verification/domain/models/driver_verification_status.dart';
import 'package:auronix_app/features/verification/domain/repositories/verification_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final AuthUnifiedRepository _repository;
  final VerificationRepository _verificationRepository;

  SessionBloc(this._repository, this._verificationRepository)
    : super(const SessionInitial()) {
    on<CheckLoggedUserEvent>(_onCheckLoggedUser);
    on<LoginUserEvent>(_onLoginUser);
    on<LoggoutUserEvent>(_onLogout);
  }

  /// Consulta `GET /drivers/me/estado-verificacion` y devuelve las
  /// credenciales del conductor con `verificationStatus` actualizado.
  /// Si la consulta falla (red caída, etc.), conserva el valor ya cacheado
  /// en `creds` — nunca lo sobrescribe con un dato desconocido (fail-closed:
  /// mientras no se confirme APROBADO, el guard del router mantiene al
  /// conductor fuera de las pantallas operativas, ver docs/flow.md sección 2).
  Future<AuthenticationCredentials> _withDriverVerificationStatus(
    AuthenticationCredentials creds,
  ) async {
    if (creds.role != Roles.rolDriver) return creds;

    final result = await _verificationRepository.getVerificationStatus();
    return result.fold((failure) {
      debugPrint(
        '[SessionBloc] No se pudo consultar estado de verificación: '
        '${failure.message}',
      );
      return creds;
    }, (status) => creds.copyWith(verificationStatus: status.estado.raw));
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
      final creds = await _withDriverVerificationStatus(driverCreds);
      emit(SessionAuthenticated(dataUser: creds));
      return;
    }

    emit(SessionUnauthenticated());
  }

  FutureOr<void> _onLoginUser(
    LoginUserEvent event,
    Emitter<SessionState> emit,
  ) async {
    final creds = await _withDriverVerificationStatus(event.dataUser);
    emit(SessionAuthenticated(dataUser: creds));
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
