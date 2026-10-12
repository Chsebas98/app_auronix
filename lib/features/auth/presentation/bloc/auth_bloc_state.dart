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
  final String email;

  const AuthUnifiedVerified({required this.email});

  @override
  List<Object?> get props => [email];
}

/// OTP code sent to `email` — awaiting the 6-digit code (docs/flow.md
/// sección 11.1). `sentAt` distingue reenvíos para que la UI reinicie el
/// cooldown incluso si el email no cambió.
final class AuthUnifiedOtpSent extends AuthUnifiedState {
  final String email;
  final DateTime sentAt;

  const AuthUnifiedOtpSent({required this.email, required this.sentAt});

  @override
  List<Object?> get props => [email, sentAt];
}

/// Auth operation failed.
final class AuthUnifiedFailure extends AuthUnifiedState {
  final Failure failure;

  const AuthUnifiedFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}
