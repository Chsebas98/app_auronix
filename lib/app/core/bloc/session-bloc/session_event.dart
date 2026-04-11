part of 'session_bloc.dart';

sealed class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object> get props => [];
}

class CheckLoggedUserEvent extends SessionEvent {}

class LoginUserEvent extends SessionEvent {
  final AuthenticationCredentials dataUser;
  const LoginUserEvent({required this.dataUser});

  @override
  List<Object> get props => [dataUser];
}

class LoggoutUserEvent extends SessionEvent {}
