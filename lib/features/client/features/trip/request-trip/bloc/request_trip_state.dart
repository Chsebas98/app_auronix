part of 'request_trip_bloc.dart';

class RequestTripState extends Equatable {
  const RequestTripState({
    this.searchResults = const [],
    this.selectedDestination,
    this.isSearching = false,
    this.errorMessage,
    this.polylinePoints = const [],
    this.isCalculatingRoute = false,
    this.distance,
    this.duration,
  });

  final List<PlaceEntity> searchResults;
  final PlaceEntity? selectedDestination;
  final bool isSearching;
  final String? errorMessage;
  final List<LatLng> polylinePoints;
  final bool isCalculatingRoute;
  final String? distance;
  final String? duration;

  RequestTripState copyWith({
    List<PlaceEntity>? searchResults,
    PlaceEntity? selectedDestination,
    bool? isSearching,
    String? errorMessage,
    bool clearDestination = false,
    List<LatLng>? polylinePoints,
    bool? isCalculatingRoute,
    String? distance,
    String? duration,
  }) {
    return RequestTripState(
      searchResults: searchResults ?? this.searchResults,
      selectedDestination: clearDestination
          ? null
          : (selectedDestination ?? this.selectedDestination),
      isSearching: isSearching ?? this.isSearching,
      errorMessage: errorMessage,
      polylinePoints: polylinePoints ?? this.polylinePoints,
      isCalculatingRoute: isCalculatingRoute ?? this.isCalculatingRoute,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [
    searchResults,
    selectedDestination,
    isSearching,
    errorMessage,
    polylinePoints,
    isCalculatingRoute,
    distance,
    duration,
  ];
}
