import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/safety/domain/models/emergency_contact.dart';
import 'package:dartz/dartz.dart';

abstract class EmergencyContactRepository {
  Future<Either<Failure, List<EmergencyContact>>> getContacts();

  Future<Either<Failure, EmergencyContact>> addContact({
    required String nombre,
    required String telefono,
    required String relacion,
  });
}
