part of 'home_driver_bloc.dart';

enum HomeDriverStatus {
  initial,
  loading,
  ready,
  tripIncoming,
  tripActive,
  error,
}

final class HomeDriverState extends Equatable {
  const HomeDriverState({
    this.status = HomeDriverStatus.initial,
    this.dataProfile = const AuthenticationCredentials.empty(),
    this.currentAddress = '',
    this.isLoadingAddress = false,
    this.isAvailable = false,
    this.incomingTrip,
    this.activeTrip,
  });

  final HomeDriverStatus status;
  final AuthenticationCredentials dataProfile; // reemplaza con tu modelo
  final String currentAddress;
  final bool isLoadingAddress;
  final bool isAvailable;
  final dynamic incomingTrip;
  final dynamic activeTrip;

  bool get isReady => status == HomeDriverStatus.ready;
  bool get hasTripIncoming => status == HomeDriverStatus.tripIncoming;
  bool get hasTripActive => status == HomeDriverStatus.tripActive;

  HomeDriverState copyWith({
    HomeDriverStatus? status,
    AuthenticationCredentials? dataProfile,
    String? currentAddress,
    bool? isLoadingAddress,
    bool? isAvailable,
    dynamic incomingTrip,
    dynamic activeTrip,
  }) {
    return HomeDriverState(
      status: status ?? this.status,
      dataProfile: dataProfile ?? this.dataProfile,
      currentAddress: currentAddress ?? this.currentAddress,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      isAvailable: isAvailable ?? this.isAvailable,
      incomingTrip: incomingTrip ?? this.incomingTrip,
      activeTrip: activeTrip ?? this.activeTrip,
    );
  }

  @override
  List<Object?> get props => [
    status,
    dataProfile,
    currentAddress,
    isLoadingAddress,
    isAvailable,
    incomingTrip,
    activeTrip,
  ];
}
