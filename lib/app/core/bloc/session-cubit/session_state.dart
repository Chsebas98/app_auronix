part of 'session_cubit.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object> get props => [];
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionAuthenticated extends SessionState {
  final AuthenticationCredentials dataUser;

  const SessionAuthenticated({required this.dataUser});

  @override
  List<Object> get props => [dataUser];
}

class SessionUnauthenticated extends SessionState {}

class SessionError extends SessionState {
  final String message;

  const SessionError(this.message);

  @override
  List<Object> get props => [message];
}

class SessionTokenExpired extends SessionState {
  final String message;

  const SessionTokenExpired({
    this.message =
        'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
  });

  @override
  List<Object> get props => [message];
}
