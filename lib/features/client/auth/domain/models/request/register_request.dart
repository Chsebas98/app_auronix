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

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.username,
    required this.nombre1,
    required this.nombre2,
    required this.ape1,
    required this.ape2,
    this.rol = Roles.rolUser,
  });

  const RegisterRequest.empty()
    : email = '',
      password = '',
      username = '',
      nombre1 = '',
      nombre2 = '',
      ape1 = '',
      ape2 = '',
      rol = Roles.rolUser;

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
  };

  @override
  String toString() => jsonEncode(toJson());
}
