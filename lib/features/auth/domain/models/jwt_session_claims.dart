import 'package:auronix_app/features/auth/domain/models/user_role.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Identidad minima leida de un JWT de acceso SIN verificar su firma
/// (la clave de firma es simetrica y vive solo en el backend — ver
/// micro-auronix JwtService). Uso exclusivo de UI (mostrar al usuario como
/// autenticado al abrir la app, T12); la seguridad real la sigue aplicando
/// el backend en cada request (un token alterado sigue siendo rechazado
/// ahi, lo que ya dispara LoggoutUserEvent via AuthInterceptor, T6).
class JwtSessionClaims {
  final String email;
  final UserRole role;
  final DateTime? expiresAt;

  const JwtSessionClaims({
    required this.email,
    required this.role,
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// null si el token esta mal formado o le faltan los claims esperados
  /// (sub, roles) — nunca lanza.
  static JwtSessionClaims? tryDecode(String token) {
    try {
      final jwt = JWT.decode(token);
      final email = jwt.subject;
      if (email == null || email.isEmpty) return null;

      final rolesClaim = jwt.payload['roles'];
      final roleValue = rolesClaim is List && rolesClaim.isNotEmpty
          ? rolesClaim.first as String?
          : null;
      if (roleValue == null) return null;
      final role = UserRole.fromBackendValue(roleValue);

      final expSeconds = jwt.payload['exp'];
      final expiresAt = expSeconds is int
          ? DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000)
          : null;

      return JwtSessionClaims(email: email, role: role, expiresAt: expiresAt);
    } catch (_) {
      return null;
    }
  }
}
