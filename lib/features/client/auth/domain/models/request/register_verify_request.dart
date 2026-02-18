import 'dart:convert';

import 'package:auronix_app/core/core.dart';

class RegisterVerifyRequest {
  final String email;
  final String password;
  final Roles rol;

  const RegisterVerifyRequest({
    required this.email,
    required this.password,
    required this.rol,
  });

  const RegisterVerifyRequest.empty()
    : email = '',
      password = '',
      rol = Roles.rolUser;

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'rol': RoleHelpers.getMnemonicoByRole(rol),
  };

  @override
  String toString() => jsonEncode(toJson());
}
