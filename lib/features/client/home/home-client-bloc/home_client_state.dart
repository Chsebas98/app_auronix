part of 'home_client_bloc.dart';

class HomeClientState extends Equatable {
  final AuthenticationCredentials dataProfile;
  final bool needCompleteProfile;
  const HomeClientState({
    this.dataProfile = const AuthenticationCredentials.empty(),
    this.needCompleteProfile = false,
  });

  HomeClientState copyWith({
    AuthenticationCredentials? dataProfile,
    bool? needCompleteProfile,
  }) {
    return HomeClientState(
      dataProfile: dataProfile ?? this.dataProfile,
      needCompleteProfile: needCompleteProfile ?? this.needCompleteProfile,
    );
  }

  @override
  List<Object> get props => [dataProfile];
}
