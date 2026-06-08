part of 'client_profile_bloc.dart';

enum ClientProfileStatus { initial, loading, ready, saving, saved, error }

final class ClientProfileState extends Equatable {
  const ClientProfileState({
    this.status = ClientProfileStatus.initial,
    this.profile = const AuthenticationCredentials.empty(),
    this.errorMessage,
  });

  final ClientProfileStatus status;
  final AuthenticationCredentials profile;
  final String? errorMessage;

  bool get isLoading =>
      status == ClientProfileStatus.loading ||
      status == ClientProfileStatus.saving;

  ClientProfileState copyWith({
    ClientProfileStatus? status,
    AuthenticationCredentials? profile,
    String? errorMessage,
  }) {
    return ClientProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
