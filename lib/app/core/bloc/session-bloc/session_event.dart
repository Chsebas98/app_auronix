part of 'session_bloc.dart';

sealed class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object> get props => [];
}

final class CheckLoggedUserEvent extends SessionEvent {
  const CheckLoggedUserEvent();
}

final class LoginUserEvent extends SessionEvent {
  final AuthenticationCredentials dataUser;
  const LoginUserEvent({required this.dataUser});

  @override
  List<Object> get props => [dataUser];
}

final class LoggoutUserEvent extends SessionEvent {
  const LoggoutUserEvent();
}
