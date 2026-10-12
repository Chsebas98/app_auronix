import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/verification/data/datasources/verification_remote_datasource.dart';
import 'package:auronix_app/features/verification/domain/models/driver_verification_status.dart';
import 'package:auronix_app/features/verification/domain/repositories/verification_repository.dart';
import 'package:dartz/dartz.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDatasource _remote;

  VerificationRepositoryImpl({required VerificationRemoteDatasource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, DriverVerificationStatus>>
  getVerificationStatus() async {
    try {
      final response = await _remote.getEstadoVerificacion();

      if (!(response['response'] as bool? ?? false)) {
        return Left(
          ServerFailure(
            message:
                response['message'] ??
                'No se pudo obtener el estado de verificación',
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
            detail: 'Falta el campo result',
            statusCode: 500,
          ),
        );
      }

      return Right(DriverVerificationStatus.fromJson(result));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al consultar la verificación',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resendVerificationEmail() async {
    try {
      final response = await _remote.resendVerificationEmail();

      if (!(response['response'] as bool? ?? false)) {
        return Left(
          ServerFailure(
            message: response['message'] ?? 'No se pudo reenviar el correo',
            detail: response['errorDetail'],
            statusCode: response['statusCode'],
          ),
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al reenviar el correo',
          detail: e.toString(),
        ),
      );
    }
  }
}
