/// Rol de un usuario tal como lo envia/espera el backend real
/// (micro-auronix `RegisterUserUseCase`/`LoginResponseDto`): las cadenas
/// literales son 'PASAJERO'/'CONDUCTOR', no 'ROL_CLIENT'/'ROL_DRIVER'
/// (ese es el enum `Roles`/`RoleHelpers` legacy de otro proyecto, que no
/// las reconoce — ver T10 en Mnemosine).
enum UserRole {
  pasajero,
  conductor;

  /// Lanza [InvalidUserRoleException] si [value] no es un rol valido —
  /// nunca cae en un rol por defecto silencioso.
  static UserRole fromBackendValue(String value) {
    switch (value.toUpperCase()) {
      case 'PASAJERO':
        return UserRole.pasajero;
      case 'CONDUCTOR':
        return UserRole.conductor;
      default:
        throw InvalidUserRoleException(value);
    }
  }

  String toBackendValue() {
    switch (this) {
      case UserRole.pasajero:
        return 'PASAJERO';
      case UserRole.conductor:
        return 'CONDUCTOR';
    }
  }
}

class InvalidUserRoleException implements Exception {
  final String rawValue;

  const InvalidUserRoleException(this.rawValue);

  @override
  String toString() =>
      'InvalidUserRoleException: rol desconocido "$rawValue" (se esperaba PASAJERO o CONDUCTOR)';
}
