part of 'emergency_contact_cubit.dart';

sealed class EmergencyContactState extends Equatable {
  const EmergencyContactState();

  @override
  List<Object?> get props => [];
}

final class EmergencyContactInitial extends EmergencyContactState {
  const EmergencyContactInitial();
}

final class EmergencyContactLoading extends EmergencyContactState {
  const EmergencyContactLoading();
}

final class EmergencyContactLoaded extends EmergencyContactState {
  final List<EmergencyContact> contacts;
  final bool isSaving;

  const EmergencyContactLoaded({required this.contacts, this.isSaving = false});

  bool get hasAtLeastOne => contacts.isNotEmpty;

  EmergencyContactLoaded copyWith({
    List<EmergencyContact>? contacts,
    bool? isSaving,
  }) {
    return EmergencyContactLoaded(
      contacts: contacts ?? this.contacts,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [contacts, isSaving];
}

final class EmergencyContactError extends EmergencyContactState {
  final String message;

  const EmergencyContactError(this.message);

  @override
  List<Object?> get props => [message];
}
