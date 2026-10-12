import 'package:auronix_app/features/trips/safety/domain/models/emergency_contact.dart';
import 'package:auronix_app/features/trips/safety/domain/repositories/emergency_contact_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'emergency_contact_state.dart';

class EmergencyContactCubit extends Cubit<EmergencyContactState> {
  final EmergencyContactRepository _repository;

  EmergencyContactCubit(this._repository)
    : super(const EmergencyContactInitial());

  Future<void> loadContacts() async {
    emit(const EmergencyContactLoading());

    final result = await _repository.getContacts();

    result.fold(
      (failure) => emit(EmergencyContactError(failure.message)),
      (contacts) => emit(EmergencyContactLoaded(contacts: contacts)),
    );
  }

  Future<bool> addContact({
    required String nombre,
    required String telefono,
    required String relacion,
  }) async {
    final current = state;
    final baseContacts = current is EmergencyContactLoaded
        ? current.contacts
        : <EmergencyContact>[];

    emit(EmergencyContactLoaded(contacts: baseContacts, isSaving: true));

    final result = await _repository.addContact(
      nombre: nombre,
      telefono: telefono,
      relacion: relacion,
    );

    return result.fold(
      (failure) {
        emit(EmergencyContactLoaded(contacts: baseContacts, isSaving: false));
        return false;
      },
      (contact) {
        emit(
          EmergencyContactLoaded(
            contacts: [...baseContacts, contact],
            isSaving: false,
          ),
        );
        return true;
      },
    );
  }
}
