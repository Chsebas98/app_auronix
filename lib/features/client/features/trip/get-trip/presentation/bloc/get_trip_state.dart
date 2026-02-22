part of 'get_trip_bloc.dart';

sealed class GetTripState extends Equatable {
  const GetTripState();
  
  @override
  List<Object> get props => [];
}

final class GetTripInitial extends GetTripState {}
