part of 'home_client_bloc.dart';

enum HomeClientStatus { initial, loading, ready, error }

final class HomeClientState extends Equatable {
  const HomeClientState({
    this.status = HomeClientStatus.initial,
    this.dataProfile = const AuthenticationCredentials.empty(),
    this.userId = 0,
    this.currentAddress = '',
    this.isLoadingAddress = false,
    this.currentTrip,
  });

  final HomeClientStatus status;
  final AuthenticationCredentials dataProfile;
  final int userId;
  final String currentAddress;
  final bool isLoadingAddress;
  final dynamic currentTrip;

  bool get isLoading => status == HomeClientStatus.loading;
  bool get isReady => status == HomeClientStatus.ready;

  HomeClientState copyWith({
    HomeClientStatus? status,
    AuthenticationCredentials? dataProfile,
    int? userId,
    String? currentAddress,
    bool? isLoadingAddress,
    dynamic currentTrip,
  }) {
    return HomeClientState(
      status: status ?? this.status,
      dataProfile: dataProfile ?? this.dataProfile,
      userId: userId ?? this.userId,
      currentAddress: currentAddress ?? this.currentAddress,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      currentTrip: currentTrip ?? this.currentTrip,
    );
  }

  @override
  List<Object?> get props => [
        status,
        dataProfile,
        userId,
        currentAddress,
        isLoadingAddress,
        currentTrip,
      ];
}
