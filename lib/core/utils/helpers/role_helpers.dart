import 'package:auronix_app/core/core.dart';

class RoleHelpers {
  /// Convierte data del backend a enum Roles
  static Roles mapRole(dynamic roleData) {
    if (roleData == null) return Roles.rolUser;

    // Si roleData es un Map (como en tu caso con role_id)
    if (roleData is Map) {
      final nemonico = roleData['nemonico_catalogo'] as String?;
      return _mapFromNemonico(nemonico);
    }

    // Si roleData es String directo
    if (roleData is String) {
      return _mapFromNemonico(roleData);
    }

    return Roles.rolUser;
  }

  /// Convierte enum Roles a nemonico del backend
  static String roleToNemonico(Roles role) {
    switch (role) {
      case Roles.rolAdmin:
        return 'ROL_ADMIN';
      case Roles.rolGerente:
        return 'ROL_GERENTE';
      case Roles.rolDriver:
        return 'ROL_DRIVER';
      case Roles.rolMember:
        return 'ROL_MEMBER';
      case Roles.rolUser:
        return 'ROL_CLIENT';
    }
  }

  /// Helper privado para mapeo centralizado
  static Roles _mapFromNemonico(String? nemonico) {
    switch (nemonico) {
      case 'ROL_CLIENT':
        return Roles.rolUser;
      case 'ROL_DRIVER':
        return Roles.rolDriver;
      case 'ROL_ADMIN':
        return Roles.rolAdmin;
      case 'ROL_GERENTE':
        return Roles.rolGerente;
      case 'ROL_MEMBER':
        return Roles.rolMember;
      default:
        return Roles.rolUser;
    }
  }

  /// Obtiene el display name para UI
  static String getRoleDisplayName(Roles role) {
    switch (role) {
      case Roles.rolAdmin:
        return 'Administrador';
      case Roles.rolGerente:
        return 'Gerente';
      case Roles.rolDriver:
        return 'Conductor';
      case Roles.rolMember:
        return 'Miembro';
      case Roles.rolUser:
        return 'Usuario';
    }
  }

  static String getMnemonicoByRole(Roles role) {
    switch (role) {
      case Roles.rolAdmin:
        return 'ROL_SUPER_ADMIN';
      case Roles.rolGerente:
        return 'ROL_MANAGER';
      case Roles.rolDriver:
        return 'ROL_DRIVER';
      case Roles.rolMember:
        return 'ROL_MEMBER';
      case Roles.rolUser:
        return 'ROL_CLIENT';
    }
  }

  /// Verifica si un rol tiene permisos de admin
  static bool isAdmin(Roles role) {
    return role == Roles.rolAdmin || role == Roles.rolGerente;
  }

  /// Verifica si un rol puede conducir
  static bool canDrive(Roles role) {
    return role == Roles.rolDriver;
  }
}
