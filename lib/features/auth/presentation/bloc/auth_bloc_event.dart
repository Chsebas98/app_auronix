part of 'auth_bloc.dart';

sealed class AuthUnifiedEvent extends Equatable {
  const AuthUnifiedEvent();

  @override
  List<Object?> get props => [];
}

final class AuthLoginClientEvent extends AuthUnifiedEvent {
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

final class AuthLoginDriverEvent extends AuthUnifiedEvent {
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

final class AuthGoogleSignInEvent extends AuthUnifiedEvent {
  const AuthGoogleSignInEvent();
}

final class AuthRegisterClientEvent extends AuthUnifiedEvent {
  final RegisterVerifyRequest verifyRequest;

  const AuthRegisterClientEvent({required this.verifyRequest});

  @override
  List<Object?> get props => [verifyRequest];
}

final class AuthRegisterDriverEvent extends AuthUnifiedEvent {
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

final class AuthRestoreClientSessionEvent extends AuthUnifiedEvent {
  const AuthRestoreClientSessionEvent();
}

final class AuthRestoreDriverSessionEvent extends AuthUnifiedEvent {
  const AuthRestoreDriverSessionEvent();
}

final class AuthLogoutEvent extends AuthUnifiedEvent {
  const AuthLogoutEvent();
}
