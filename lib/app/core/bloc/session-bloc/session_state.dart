part of 'session_bloc.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object> get props => [];
}

final class SessionInitial extends SessionState {
  const SessionInitial();
}

final class SessionLoading extends SessionState {
  const SessionLoading();
}

final class SessionAuthenticated extends SessionState {
  final AuthenticationCredentials dataUser;

  const SessionAuthenticated({required this.dataUser});

  @override
  List<Object> get props => [dataUser];
}

final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

final class SessionError extends SessionState {
  final String message;

  const SessionError(this.message);

  @override
  List<Object> get props => [message];
}

final class SessionTokenExpired extends SessionState {
  final String message;

  const SessionTokenExpired({
    this.message =
        'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
  });

  @override
  List<Object> get props => [message];
}
