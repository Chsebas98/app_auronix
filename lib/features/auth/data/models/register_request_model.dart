import 'package:auronix_app/features/auth/domain/models/user_role.dart';

/// DTO del body real de `POST /api/v1/auth/register` (`RegisterUserRequestDto`):
/// campos comunes (email, password, firstName, lastName, cedula, tipo) mas
/// los exclusivos de conductor (cooperativaId, licenciaConducir,
/// tipoLicencia, fechaVencimientoLicencia), que el backend ignora si el
/// tipo es PASAJERO.
class RegisterRequestModel {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String cedula;
  final UserRole role;
  final int? cooperativaId;
  final String? licenciaConducir;
  final String? tipoLicencia;
  final String? fechaVencimientoLicencia;

  const RegisterRequestModel({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.cedula,
    required this.role,
    this.cooperativaId,
    this.licenciaConducir,
    this.tipoLicencia,
    this.fechaVencimientoLicencia,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    'cedula': cedula,
    'tipo': role.toBackendValue(),
    if (cooperativaId != null) 'cooperativaId': cooperativaId,
    if (licenciaConducir != null) 'licenciaConducir': licenciaConducir,
    if (tipoLicencia != null) 'tipoLicencia': tipoLicencia,
    if (fechaVencimientoLicencia != null)
      'fechaVencimientoLicencia': fechaVencimientoLicencia,
  };
}
