part of 'home_client_bloc.dart';

class HomeClientState extends Equatable {
  const HomeClientState({
    this.dataProfile = const AuthenticationCredentials.empty(),
    this.needCompleteProfile = false,
    this.completeProfileStatus = const InitialFormSubmitStatus(),
    this.currentTrip,
  });

  final AuthenticationCredentials dataProfile;
  final bool needCompleteProfile;
  final FormSubmitStatus completeProfileStatus;
  final TripModel? currentTrip;

  HomeClientState copyWith({
    AuthenticationCredentials? dataProfile,
    bool? needCompleteProfile,
    FormSubmitStatus? completeProfileStatus,
    TripModel? currentTrip,
    bool clearCurrentTrip = false,
  }) {
    return HomeClientState(
      dataProfile: dataProfile ?? this.dataProfile,
      needCompleteProfile: needCompleteProfile ?? this.needCompleteProfile,
      completeProfileStatus:
          completeProfileStatus ?? this.completeProfileStatus,
      currentTrip: clearCurrentTrip ? null : (currentTrip ?? this.currentTrip),
    );
  }

  @override
  List<Object?> get props => [
    dataProfile,
    needCompleteProfile,
    completeProfileStatus,
    currentTrip,
  ];
}
