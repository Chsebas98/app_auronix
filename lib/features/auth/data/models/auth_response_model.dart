import 'package:auronix_app/features/auth/domain/models/auth_tokens.dart';
import 'package:auronix_app/features/auth/domain/models/user_data.dart';
import 'package:auronix_app/features/auth/domain/models/user_role.dart';

/// DTO del login/registro real del backend (`LoginResponseDto`): campos
/// `userId`, `email`, `roles` (lista, se toma el primero), `accessToken`,
/// `refreshToken`. Inmutable; cualquier campo requerido ausente o con el
/// tipo incorrecto lanza [MalformedAuthResponseException] en vez de un
/// TypeError/NoSuchMethodError crudo.
class AuthResponseModel {
  final int id;
  final String email;
  final UserRole role;
  final String accessToken;
  final String refreshToken;

  const AuthResponseModel({
    required this.id,
    required this.email,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final id = json['userId'] ?? json['id'];
    if (id is! int) {
      throw const MalformedAuthResponseException(
        'userId/id falta o no es entero',
      );
    }

    final email = json['email'];
    if (email is! String || email.isEmpty) {
      throw const MalformedAuthResponseException('email falta o esta vacio');
    }

    final rawRole = _extractRole(json['roles'] ?? json['role']);
    if (rawRole == null) {
      throw const MalformedAuthResponseException('roles/role falta');
    }

    final accessToken = json['accessToken'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const MalformedAuthResponseException(
        'accessToken falta o esta vacio',
      );
    }

    final refreshToken = json['refreshToken'];
    if (refreshToken is! String || refreshToken.isEmpty) {
      throw const MalformedAuthResponseException(
        'refreshToken falta o esta vacio',
      );
    }

    return AuthResponseModel(
      id: id,
      email: email,
      role: UserRole.fromBackendValue(rawRole),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  static String? _extractRole(dynamic raw) {
    if (raw is String) return raw;
    if (raw is List && raw.isNotEmpty && raw.first is String) {
      return raw.first as String;
    }
    return null;
  }

  UserData toUserData() => UserData(id: id, email: email, role: role);

  AuthTokens toAuthTokens() =>
      AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
}

class MalformedAuthResponseException implements Exception {
  final String reason;

  const MalformedAuthResponseException(this.reason);

  @override
  String toString() => 'MalformedAuthResponseException: $reason';
}
