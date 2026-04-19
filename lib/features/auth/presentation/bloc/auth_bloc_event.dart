part of 'auth_bloc.dart';

abstract class AuthUnifiedEvent extends Equatable {
  const AuthUnifiedEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginClientEvent extends AuthUnifiedEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const AuthLoginClientEvent({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class AuthLoginDriverEvent extends AuthUnifiedEvent {
  final String ciPassport;
  final String password;
  final bool rememberMe;

  const AuthLoginDriverEvent({
    required this.ciPassport,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [ciPassport, password, rememberMe];
}

class AuthGoogleSignInEvent extends AuthUnifiedEvent {
  const AuthGoogleSignInEvent();
}

class AuthRegisterClientEvent extends AuthUnifiedEvent {
  final RegisterVerifyRequest verifyRequest;

  const AuthRegisterClientEvent({required this.verifyRequest});

  @override
  List<Object?> get props => [verifyRequest];
}

class AuthRegisterDriverEvent extends AuthUnifiedEvent {
  final String ciPassport;
  final String password;
  final String email;

  const AuthRegisterDriverEvent({
    required this.ciPassport,
    required this.password,
    required this.email,
  });

  @override
  List<Object?> get props => [ciPassport, password, email];
}

class AuthRestoreClientSessionEvent extends AuthUnifiedEvent {
  const AuthRestoreClientSessionEvent();
}

class AuthRestoreDriverSessionEvent extends AuthUnifiedEvent {
  const AuthRestoreDriverSessionEvent();
}

class AuthLogoutEvent extends AuthUnifiedEvent {
  const AuthLogoutEvent();
}
