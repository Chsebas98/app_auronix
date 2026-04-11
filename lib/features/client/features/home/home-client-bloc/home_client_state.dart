part of 'home_client_bloc.dart';

class HomeClientState extends Equatable {
  const HomeClientState({
    this.dataProfile = const AuthenticationCredentials.empty(),
    this.needCompleteProfile = false,
    this.completeProfileStatus = const InitialFormSubmitStatus(),
    this.currentTrip,
    this.currentAddress = '',
    this.isLoadingAddress = false,
  });

  final AuthenticationCredentials dataProfile;
  final bool needCompleteProfile;
  final FormSubmitStatus completeProfileStatus;
  final TripModel? currentTrip;
  final String currentAddress;
  final bool isLoadingAddress;

  HomeClientState copyWith({
    AuthenticationCredentials? dataProfile,
    bool? needCompleteProfile,
    FormSubmitStatus? completeProfileStatus,
    TripModel? currentTrip,
    bool clearCurrentTrip = false,
    String? currentAddress,
    bool? isLoadingAddress,
  }) {
    return HomeClientState(
      dataProfile: dataProfile ?? this.dataProfile,
      needCompleteProfile: needCompleteProfile ?? this.needCompleteProfile,
      completeProfileStatus:
          completeProfileStatus ?? this.completeProfileStatus,
      currentTrip: clearCurrentTrip ? null : (currentTrip ?? this.currentTrip),
      currentAddress: currentAddress ?? this.currentAddress,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
    );
  }

  @override
  List<Object?> get props => [
    dataProfile,
    needCompleteProfile,
    completeProfileStatus,
    currentTrip,
    currentAddress,
    isLoadingAddress,
  ];
}
