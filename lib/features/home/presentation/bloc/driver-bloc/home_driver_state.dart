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
    this.gpsRequired = false,
    this.emergencyContactRequired = false,
    this.incomingTrip,
    this.activeTrip,
    this.dailyEarnings = 0.0,
    this.completedTrips = 0,
    this.earningsHistory = const [],
  });

  final HomeDriverStatus status;
  final AuthenticationCredentials dataProfile;
  final String currentAddress;
  final bool isLoadingAddress;
  final bool isAvailable;
  final bool gpsRequired;
  final bool emergencyContactRequired;
  final dynamic incomingTrip;
  final dynamic activeTrip;
  final double dailyEarnings;
  final int completedTrips;
  final List<EarningsPoint> earningsHistory;

  bool get isReady => status == HomeDriverStatus.ready;
  bool get hasTripIncoming => status == HomeDriverStatus.tripIncoming;
  bool get hasTripActive => status == HomeDriverStatus.tripActive;

  HomeDriverState copyWith({
    HomeDriverStatus? status,
    AuthenticationCredentials? dataProfile,
    String? currentAddress,
    bool? isLoadingAddress,
    bool? isAvailable,
    bool? gpsRequired,
    bool? emergencyContactRequired,
    dynamic incomingTrip,
    dynamic activeTrip,
    double? dailyEarnings,
    int? completedTrips,
    List<EarningsPoint>? earningsHistory,
  }) {
    return HomeDriverState(
      status: status ?? this.status,
      dataProfile: dataProfile ?? this.dataProfile,
      currentAddress: currentAddress ?? this.currentAddress,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      isAvailable: isAvailable ?? this.isAvailable,
      gpsRequired: gpsRequired ?? this.gpsRequired,
      emergencyContactRequired:
          emergencyContactRequired ?? this.emergencyContactRequired,
      incomingTrip: incomingTrip ?? this.incomingTrip,
      activeTrip: activeTrip ?? this.activeTrip,
      dailyEarnings: dailyEarnings ?? this.dailyEarnings,
      completedTrips: completedTrips ?? this.completedTrips,
      earningsHistory: earningsHistory ?? this.earningsHistory,
    );
  }

  @override
  List<Object?> get props => [
    status,
    dataProfile,
    currentAddress,
    isLoadingAddress,
    isAvailable,
    gpsRequired,
    emergencyContactRequired,
    incomingTrip,
    activeTrip,
    dailyEarnings,
    completedTrips,
    earningsHistory,
  ];
}
