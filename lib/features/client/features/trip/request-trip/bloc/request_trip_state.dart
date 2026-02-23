part of 'request_trip_bloc.dart';

class RequestTripState extends Equatable {
  const RequestTripState({
    this.searchResults = const [],
    this.selectedDestination,
    this.isSearching = false,
    this.errorMessage,
  });

  final List<PlaceEntity> searchResults;
  final PlaceEntity? selectedDestination;
  final bool isSearching;
  final String? errorMessage;

  RequestTripState copyWith({
    List<PlaceEntity>? searchResults,
    PlaceEntity? selectedDestination,
    bool? isSearching,
    String? errorMessage,
    bool clearDestination = false,
  }) {
    return RequestTripState(
      searchResults: searchResults ?? this.searchResults,
      selectedDestination: clearDestination
          ? null
          : (selectedDestination ?? this.selectedDestination),
      isSearching: isSearching ?? this.isSearching,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    searchResults,
    selectedDestination,
    isSearching,
    errorMessage,
  ];
}
