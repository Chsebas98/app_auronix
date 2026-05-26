import 'dart:convert';

class RegisterDriverRequest {
  final String email;
  final String password;
  final String firstName;
  final String? secondName;
  final String lastName;
  final String? secondLastName;
  final String cedula;
  final String licenciaConducir;
  final String tipoLicencia;
  final String fechaVencimientoLicencia;
  final int cooperativaId;

  const RegisterDriverRequest({
    required this.email,
    required this.password,
    required this.firstName,
    this.secondName,
    required this.lastName,
    this.secondLastName,
    required this.cedula,
    required this.licenciaConducir,
    required this.tipoLicencia,
    required this.fechaVencimientoLicencia,
    required this.cooperativaId,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'first_name': firstName,
    'second_name': secondName,
    'last_name': lastName,
    'second_last_name': secondLastName,
    'cedula': cedula,
    'licencia_conducir': licenciaConducir,
    'tipo_licencia': tipoLicencia,
    'fecha_vencimiento_licencia': fechaVencimientoLicencia,
    'cooperativa_id': cooperativaId,
  };

  @override
  String toString() => jsonEncode(toJson());
}
