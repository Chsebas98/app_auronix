part of 'home_client_bloc.dart';

sealed class HomeClientEvent extends Equatable {
  const HomeClientEvent();

  @override
  List<Object> get props => [];
}

class GetDataProfileEvent extends HomeClientEvent {}
