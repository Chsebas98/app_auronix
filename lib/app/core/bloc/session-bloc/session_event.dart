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
  const LoginUserEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LoggoutUserEvent extends SessionEvent {}
