part of 'client_profile_bloc.dart';

sealed class ClientProfileEvent extends Equatable {
  const ClientProfileEvent();
  @override
  List<Object?> get props => [];
}

final class ClientProfileLoadEvent extends ClientProfileEvent {
  final int userId;
  const ClientProfileLoadEvent({required this.userId});
  @override
  List<Object?> get props => [userId];
}

final class ClientProfileUpdateEvent extends ClientProfileEvent {
  final int userId;
  final String? firstName;
  final String? secondName;
  final String? lastName;
  final String? secondLastName;
  final String? phone;
  final String? photoUrl;

  const ClientProfileUpdateEvent({
    required this.userId,
    this.firstName,
    this.secondName,
    this.lastName,
    this.secondLastName,
    this.phone,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [userId, firstName, lastName, phone];
}
