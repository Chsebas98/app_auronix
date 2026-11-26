import 'package:auronix_app/features/auth/domain/models/user_role.dart';

/// Entidad de dominio del usuario autenticado (id, email, rol) — separada de
/// `AuthenticationCredentials` (que ademas carga tokens, nombre completo y
/// datos de perfil ya persistidos localmente). `UserData` es el identity
/// minimo que el backend confirma al hacer login/registro.
class UserData {
  final int id;
  final String email;
  final UserRole role;

  const UserData({required this.id, required this.email, required this.role});

  @override
  bool operator ==(Object other) =>
      other is UserData &&
      other.id == id &&
      other.email == email &&
      other.role == role;

  @override
  int get hashCode => Object.hash(id, email, role);
}
