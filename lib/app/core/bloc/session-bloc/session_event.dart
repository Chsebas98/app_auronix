part of 'session_bloc.dart';

sealed class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object> get props => [];
}

class CheckLoggedUserEvent extends SessionEvent {}

class LoginUserEvent extends SessionEvent {
  final String email;
  final String password;
  final AuthenticationCredentials isGoogle;
  const LoginUserEvent({
    required this.email,
    required this.password,
    this.isGoogle = const AuthenticationCredentials.empty(),
  });

  @override
  List<Object> get props => [email, password, isGoogle];
}

class LoggoutUserEvent extends SessionEvent {}
