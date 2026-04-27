part of 'home_client_bloc.dart';

sealed class HomeClientState extends Equatable {
  const HomeClientState();
  
  @override
  List<Object> get props => [];
}

final class HomeClientInitial extends HomeClientState {}
