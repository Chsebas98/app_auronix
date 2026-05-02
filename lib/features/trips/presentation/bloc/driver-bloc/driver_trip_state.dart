part of 'driver_trip_bloc.dart';

final class DriverTripState extends Equatable {
  const DriverTripState({
    this.status = DriverTripStatus.initial,
    this.nearbyRequests = const [],
    this.selectedRequest,
    this.driverPosition,
  });

  final DriverTripStatus status;
  final List<TripRequest> nearbyRequests;
  final TripRequest? selectedRequest;
  final LatLng? driverPosition;

  bool get hasSelectedRequest => selectedRequest != null;

  DriverTripState copyWith({
    DriverTripStatus? status,
    List<TripRequest>? nearbyRequests,
    TripRequest? selectedRequest,
    bool clearSelected = false,
    LatLng? driverPosition,
  }) {
    return DriverTripState(
      status: status ?? this.status,
      nearbyRequests: nearbyRequests ?? this.nearbyRequests,
      selectedRequest: clearSelected
          ? null
          : selectedRequest ?? this.selectedRequest,
      driverPosition: driverPosition ?? this.driverPosition,
    );
  }

  @override
  List<Object?> get props => [
    status,
    nearbyRequests,
    selectedRequest,
    driverPosition,
  ];
}

enum DriverTripStatus { initial, loading, ready, accepting, error }
