part of 'auth_bloc.dart';

/// Sealed states for auth operations (login, register, logout, restore session).
sealed class AuthUnifiedState extends Equatable {
  const AuthUnifiedState();

  @override
  List<Object?> get props => [];
}

/// No ongoing auth operation — waiting for user action.
final class AuthUnifiedIdle extends AuthUnifiedState {
  const AuthUnifiedIdle();
}

/// Auth operation in progress.
final class AuthUnifiedLoading extends AuthUnifiedState {
  const AuthUnifiedLoading();
}

/// Auth operation succeeded.
final class AuthUnifiedSuccess extends AuthUnifiedState {
  final AuthenticationCredentials credentials;

  const AuthUnifiedSuccess({required this.credentials});

  @override
  List<Object?> get props => [credentials];
}

/// Email/OTP verification step passed — awaiting full registration data.
final class AuthUnifiedVerified extends AuthUnifiedState {
  const AuthUnifiedVerified();
}

final class AuthUnifiedRegistering extends AuthUnifiedState {
  final String email;
  const AuthUnifiedRegistering({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Auth operation failed.
final class AuthUnifiedFailure extends AuthUnifiedState {
  final Failure failure;

  const AuthUnifiedFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}
