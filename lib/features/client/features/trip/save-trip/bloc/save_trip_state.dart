part of 'save_trip_bloc.dart';

sealed class SaveTripState extends Equatable {
  const SaveTripState();
  
  @override
  List<Object> get props => [];
}

final class SaveTripInitial extends SaveTripState {}
