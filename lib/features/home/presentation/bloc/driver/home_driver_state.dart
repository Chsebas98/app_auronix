part of 'home_driver_bloc.dart';

sealed class HomeDriverState extends Equatable {
  const HomeDriverState();
  
  @override
  List<Object> get props => [];
}

final class HomeDriverInitial extends HomeDriverState {}
