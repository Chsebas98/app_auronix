import 'dart:async';
import 'package:auronix_app/app/core/network/secure_storage_service.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/models/jwt_session_claims.dart';
import 'package:auronix_app/features/auth/domain/models/user_role.dart';
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
  final SecureStorageService _secureStorage;

  SessionBloc(
    this._repository,
    this._prefs, {
    SecureStorageService? secureStorage,
  }) : _secureStorage = secureStorage ?? SecureStorageServiceImpl(),
       super(const SessionInitial()) {
    on<CheckLoggedUserEvent>(_onCheckLoggedUser);
    on<LoginUserEvent>(_onLoginUser);
    on<LoggoutUserEvent>(_onLogout);
  }

  FutureOr<void> _onCheckLoggedUser(
    CheckLoggedUserEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());

    // T12: la sesion "real" (login contra el backend, T11) persiste su JWT
    // en SecureStorageService, no en el SQLite legacy que revisa el resto
    // de este metodo. Se chequea primero — si hay un token valido y vigente
    // ahi, se reconstruye la identidad desde sus claims (sin red: un token
    // alterado igual lo rechaza el backend en el siguiente request real,
    // via AuthInterceptor, T6).
    final secureTokenResult = await _secureStorage.getAccessToken();
    final secureToken = secureTokenResult.fold((_) => null, (t) => t);
    if (secureToken != null && secureToken.isNotEmpty) {
      final claims = JwtSessionClaims.tryDecode(secureToken);
      if (claims != null && !claims.isExpired) {
        debugPrint('[Session] restored session from SecureStorageService JWT');
        emit(
          SessionAuthenticated(
            dataUser: _credentialsFromClaims(claims, secureToken),
          ),
        );
        return;
      }
    }

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

  void _onLoginUser(LoginUserEvent event, Emitter<SessionState> emit) {
    emit(SessionAuthenticated(dataUser: event.dataUser));
  }

  FutureOr<void> _onLogout(
    LoggoutUserEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    await _repository.logout();
    // T16: logout() solo limpia el SQLite legacy — la sesion "real" (T11/T12)
    // vive en SecureStorageService y debe borrarse tambien, o un proximo
    // arranque de la app la restaura via _onCheckLoggedUser.
    await _secureStorage.clearSession();
    emit(SessionUnauthenticated());
  }

  AuthenticationCredentials _credentialsFromClaims(
    JwtSessionClaims claims,
    String accessToken,
  ) {
    return AuthenticationCredentials(
      tokenAccess: accessToken,
      tokenRefresh: '',
      role: claims.role == UserRole.conductor ? Roles.rolDriver : Roles.rolUser,
      username: claims.email,
      firstName: '',
      secondName: null,
      lastName: '',
      secondlastName: '',
      email: claims.email,
    );
  }
}
