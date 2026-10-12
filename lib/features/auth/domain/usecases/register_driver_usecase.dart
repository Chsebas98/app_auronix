import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:dartz/dartz.dart';

class RegisterDriverUseCase {
  final AuthUnifiedRepository _repository;

  RegisterDriverUseCase(this._repository);

  Future<Either<Failure, AuthenticationCredentials>> call({
    required String ciPassport,
    required String password,
    required String email,
    String? licenseNumber,
    String? licenseType,
    String? plateNumber,
    String? vehicleBrand,
    String? vehicleModel,
    String? vehicleYear,
    DateTime? birthDate,
    String? terminosVersion,
    DateTime? terminosAceptadosEn,
  }) {
    return _repository.registerDriver(
      ciPassport: ciPassport,
      password: password,
      email: email,
      licenseNumber: licenseNumber,
      licenseType: licenseType,
      plateNumber: plateNumber,
      vehicleBrand: vehicleBrand,
      vehicleModel: vehicleModel,
      vehicleYear: vehicleYear,
      birthDate: birthDate,
      terminosVersion: terminosVersion,
      terminosAceptadosEn: terminosAceptadosEn,
    );
  }
}
