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
    this.currentLat = 0,
    this.currentLng = 0,
    this.isLoadingAddress = false,
    this.isAvailable = false,
    this.incomingTrip,
    this.activeTrip,
    this.dailyEarnings = 0.0,
    this.completedTrips = 0,
    this.earningsHistory = const [],
    this.errorMessage,
  });

  final HomeDriverStatus status;
  final AuthenticationCredentials dataProfile;
  final String currentAddress;
  final double currentLat;
  final double currentLng;
  final bool isLoadingAddress;
  final bool isAvailable;
  final dynamic incomingTrip;
  final dynamic activeTrip;
  final double dailyEarnings;
  final int completedTrips;
  final List<EarningsPoint> earningsHistory;
  final String? errorMessage;

  bool get isReady => status == HomeDriverStatus.ready;
  bool get hasTripIncoming => status == HomeDriverStatus.tripIncoming;
  bool get hasTripActive => status == HomeDriverStatus.tripActive;

  HomeDriverState copyWith({
    HomeDriverStatus? status,
    AuthenticationCredentials? dataProfile,
    String? currentAddress,
    double? currentLat,
    double? currentLng,
    bool? isLoadingAddress,
    bool? isAvailable,
    dynamic incomingTrip,
    dynamic activeTrip,
    double? dailyEarnings,
    int? completedTrips,
    List<EarningsPoint>? earningsHistory,
    String? errorMessage,
  }) {
    return HomeDriverState(
      status: status ?? this.status,
      dataProfile: dataProfile ?? this.dataProfile,
      currentAddress: currentAddress ?? this.currentAddress,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      isAvailable: isAvailable ?? this.isAvailable,
      incomingTrip: incomingTrip ?? this.incomingTrip,
      activeTrip: activeTrip ?? this.activeTrip,
      dailyEarnings: dailyEarnings ?? this.dailyEarnings,
      completedTrips: completedTrips ?? this.completedTrips,
      earningsHistory: earningsHistory ?? this.earningsHistory,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    dataProfile,
    currentAddress,
    currentLat,
    currentLng,
    isLoadingAddress,
    isAvailable,
    incomingTrip,
    activeTrip,
    dailyEarnings,
    completedTrips,
    earningsHistory,
    errorMessage,
  ];
}
