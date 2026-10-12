import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/safety/data/datasources/emergency_contact_remote_datasource.dart';
import 'package:auronix_app/features/trips/safety/domain/models/emergency_contact.dart';
import 'package:auronix_app/features/trips/safety/domain/repositories/emergency_contact_repository.dart';
import 'package:dartz/dartz.dart';

class EmergencyContactRepositoryImpl implements EmergencyContactRepository {
  final EmergencyContactRemoteDatasource _remote;

  EmergencyContactRepositoryImpl({
    required EmergencyContactRemoteDatasource remote,
  }) : _remote = remote;

  @override
  Future<Either<Failure, List<EmergencyContact>>> getContacts() async {
    try {
      final response = await _remote.getContacts();

      if (!(response['response'] as bool? ?? false)) {
        return Left(
          ServerFailure(
            message:
                response['message'] ??
                'No se pudieron obtener los contactos de emergencia',
            detail: response['errorDetail'],
            statusCode: response['statusCode'],
          ),
        );
      }

      final result = response['result'];
      if (result is! List) return const Right([]);

      return Right(
        result
            .whereType<Map<String, dynamic>>()
            .map(EmergencyContact.fromJson)
            .toList(),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al consultar contactos de emergencia',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, EmergencyContact>> addContact({
    required String nombre,
    required String telefono,
    required String relacion,
  }) async {
    try {
      final response = await _remote.addContact(
        nombre: nombre,
        telefono: telefono,
        relacion: relacion,
      );

      if (!(response['response'] as bool? ?? false)) {
        return Left(
          ServerFailure(
            message:
                response['message'] ??
                'No se pudo guardar el contacto de emergencia',
            detail: response['errorDetail'],
            statusCode: response['statusCode'],
          ),
        );
      }

      final result = response['result'] as Map<String, dynamic>?;
      if (result == null) {
        return const Left(
          ServerFailure(
            message: 'Respuesta inválida del servidor',
            statusCode: 500,
          ),
        );
      }

      return Right(EmergencyContact.fromJson(result));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al guardar el contacto de emergencia',
          detail: e.toString(),
        ),
      );
    }
  }
}
