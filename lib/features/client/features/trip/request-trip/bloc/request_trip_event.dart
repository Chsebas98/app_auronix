part of 'request_trip_bloc.dart';

sealed class RequestTripEvent extends Equatable {
  const RequestTripEvent();

  @override
  List<Object?> get props => [];
}

class SearchDestinationEvent extends RequestTripEvent {
  final String query;

  const SearchDestinationEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectDestinationEvent extends RequestTripEvent {
  final PlaceEntity destination;

  const SelectDestinationEvent(this.destination);

  @override
  List<Object?> get props => [destination];
}

class ClearSearchEvent extends RequestTripEvent {
  const ClearSearchEvent();
}

class CalculateRouteEvent extends RequestTripEvent {
  final LatLng origin;
  final PlaceEntity destination;

  const CalculateRouteEvent({required this.origin, required this.destination});

  @override
  List<Object?> get props => [origin, destination];
}
