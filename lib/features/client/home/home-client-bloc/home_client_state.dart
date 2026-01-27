part of 'home_client_bloc.dart';

class HomeClientState extends Equatable {
  final AuthenticationCredentials dataProfile;
  final bool needCompleteProfile;
  final FormSubmitStatus completeProfileStatus;
  const HomeClientState({
    this.dataProfile = const AuthenticationCredentials.empty(),
    this.needCompleteProfile = false,
    this.completeProfileStatus = const InitialFormSubmitStatus(),
  });

  HomeClientState copyWith({
    AuthenticationCredentials? dataProfile,
    bool? needCompleteProfile,
    FormSubmitStatus? completeProfileStatus,
  }) {
    return HomeClientState(
      dataProfile: dataProfile ?? this.dataProfile,
      needCompleteProfile: needCompleteProfile ?? this.needCompleteProfile,
      completeProfileStatus:
          completeProfileStatus ?? this.completeProfileStatus,
    );
  }

  @override
  List<Object> get props => [
    dataProfile,
    needCompleteProfile,
    completeProfileStatus,
  ];
}
