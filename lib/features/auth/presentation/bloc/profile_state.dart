part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileActionSuccess extends ProfileState {
  final String message;

  const ProfileActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

final class ProfileAccountDeleted extends ProfileState {
  const ProfileAccountDeleted();
}

final class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
