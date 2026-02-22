part of 'request_trip_bloc.dart';

sealed class RequestTripState extends Equatable {
  const RequestTripState();
  
  @override
  List<Object> get props => [];
}

final class RequestTripInitial extends RequestTripState {}
