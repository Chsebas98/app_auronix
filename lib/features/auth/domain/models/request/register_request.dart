import 'dart:convert';

import 'package:auronix_app/core/core.dart';

class RegisterRequest {
  final String email;
  final String password;
  final String username;
  final String nombre1;
  final String nombre2;
  final String ape1;
  final String ape2;
  final Roles rol;

  /// Campos de docs/database.md (`usuario.telefono`, `fecha_nacimiento`,
  /// `terminos_version`, `terminos_aceptados_en`) — obligatorios por regla
  /// de negocio (docs/flow.md sección 11.1) pero el nombre exacto de estas
  /// claves en el payload de `POST /auth/{clients|drivers}/register` no
  /// está confirmado todavía por backend (ver docs/requerimientos_backend.md
  /// sección 9). Se envían con el nombre de columna de la BD como mejor
  /// aproximación disponible — verificar contra el backend real.
  final String? telefono;
  final DateTime? fechaNacimiento;
  final String? terminosVersion;
  final DateTime? terminosAceptadosEn;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.username,
    required this.nombre1,
    required this.nombre2,
    required this.ape1,
    required this.ape2,
    this.rol = Roles.rolUser,
    this.telefono,
    this.fechaNacimiento,
    this.terminosVersion,
    this.terminosAceptadosEn,
  });

  const RegisterRequest.empty()
    : email = '',
      password = '',
      username = '',
      nombre1 = '',
      nombre2 = '',
      ape1 = '',
      ape2 = '',
      rol = Roles.rolUser,
      telefono = null,
      fechaNacimiento = null,
      terminosVersion = null,
      terminosAceptadosEn = null;

  RegisterRequest copyWithNames({
    String? nombre1,
    String? nombre2,
    String? ape1,
    String? ape2,
  }) {
    return RegisterRequest(
      email: email,
      password: password,
      username: username,
      rol: rol,
      nombre1: nombre1 ?? this.nombre1,
      nombre2: nombre2 ?? this.nombre2,
      ape1: ape1 ?? this.ape1,
      ape2: ape2 ?? this.ape2,
      telefono: telefono,
      fechaNacimiento: fechaNacimiento,
      terminosVersion: terminosVersion,
      terminosAceptadosEn: terminosAceptadosEn,
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'username': username,
    'nombre1': nombre1,
    'nombre2': nombre2,
    'ape1': ape1,
    'ape2': ape2,
    'rol': RoleHelpers.getMnemonicoByRole(rol),
    if (telefono != null) 'telefono': telefono,
    if (fechaNacimiento != null)
      'fecha_nacimiento': fechaNacimiento!.toIso8601String(),
    if (terminosVersion != null) 'terminos_version': terminosVersion,
    if (terminosAceptadosEn != null)
      'terminos_aceptados_en': terminosAceptadosEn!.toIso8601String(),
  };

  @override
  String toString() => jsonEncode(toJson());
}
