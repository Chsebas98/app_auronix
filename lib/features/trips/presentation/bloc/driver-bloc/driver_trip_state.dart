part of 'driver_trip_bloc.dart';

final class DriverTripState extends Equatable {
  const DriverTripState({
    this.status = DriverTripStatus.initial,
    this.nearbyRequests = const [],
    this.selectedRequest,
    this.activeTrip,
    this.completedTrip,
    this.driverPosition,
    this.errorMessage,
  });

  final DriverTripStatus status;
  final List<TripRequest> nearbyRequests;
  final TripRequest? selectedRequest;
  final TripEntity? activeTrip;
  final CompleteTripResult? completedTrip;
  final LatLng? driverPosition;
  final String? errorMessage;

  bool get hasSelectedRequest => selectedRequest != null;

  DriverTripState copyWith({
    DriverTripStatus? status,
    List<TripRequest>? nearbyRequests,
    TripRequest? selectedRequest,
    bool clearSelected = false,
    TripEntity? activeTrip,
    CompleteTripResult? completedTrip,
    LatLng? driverPosition,
    String? errorMessage,
  }) {
    return DriverTripState(
      status: status ?? this.status,
      nearbyRequests: nearbyRequests ?? this.nearbyRequests,
      selectedRequest:
          clearSelected ? null : selectedRequest ?? this.selectedRequest,
      activeTrip: activeTrip ?? this.activeTrip,
      completedTrip: completedTrip ?? this.completedTrip,
      driverPosition: driverPosition ?? this.driverPosition,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        nearbyRequests,
        selectedRequest,
        activeTrip,
        completedTrip,
        driverPosition,
        errorMessage,
      ];
}

enum DriverTripStatus {
  initial,
  loading,
  ready,
  accepting,
  accepted,
  starting,
  inProgress,
  completing,
  completed,
  rating,
  rated,
  error,
}
