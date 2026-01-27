import 'package:auronix_app/core/models/interfaces/interfaces.dart';
import 'package:auronix_app/features/features.dart';

/// Response de Strapi para usuarios
class StrapiUserResponse {
  final int id;
  final String documentId;
  final String email;
  final String username;
  final String nombre1;
  final String? nombre2;
  final String? ape1;
  final String? ape2;
  final String? photoUrl;
  final String? tokenAccess;
  final bool inicioGoogle;
  final bool estadoUser;
  final bool bloqueado;
  final StrapiRole? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StrapiUserResponse({
    required this.id,
    required this.documentId,
    required this.email,
    required this.username,
    required this.nombre1,
    this.nombre2,
    this.ape1,
    this.ape2,
    this.photoUrl,
    this.tokenAccess,
    required this.inicioGoogle,
    required this.estadoUser,
    required this.bloqueado,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory StrapiUserResponse.fromJson(Map<String, dynamic> json) {
    return StrapiUserResponse(
      id: json['id'] as int,
      documentId: json['documentId'] as String,
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      nombre1: json['nombre1'] as String? ?? '',
      nombre2: json['nombre2'] as String?,
      ape1: json['ape1'] as String?,
      ape2: json['ape2'] as String?,
      photoUrl: json['photo_url'] as String?,
      tokenAccess: json['token_access'] as String?,
      inicioGoogle: json['inicio_google'] as bool? ?? false,
      estadoUser: json['estado_user'] as bool? ?? true,
      bloqueado: json['bloqueado'] as bool? ?? false,
      role: json['role'] != null
          ? StrapiRole.fromJson(json['role'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'email': email,
      'username': username,
      'nombre1': nombre1,
      'nombre2': nombre2,
      'ape1': ape1,
      'ape2': ape2,
      'photo_url': photoUrl,
      'token_access': tokenAccess,
      'inicio_google': inicioGoogle,
      'estado_user': estadoUser,
      'bloqueado': bloqueado,
      'role': role?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convierte StrapiUserResponse a AuthenticationCredentials
  AuthenticationCredentials toAuthCredentials({String? googleToken}) {
    return AuthenticationCredentials(
      token: googleToken ?? tokenAccess ?? '',
      username: username,
      firstName: nombre1,
      secondName: nombre2 ?? '',
      lastName: ape1 ?? '',
      secondlastName: ape2 ?? '',
      email: email,
      photoUrl: photoUrl ?? '',
      role: _mapRole(role?.nemonicoCatalogo),
      isGoogleUser: inicioGoogle,
    );
  }

  /// Mapea el rol de Strapi a tu enum Roles
  Roles _mapRole(String? nemonico) {
    switch (nemonico) {
      case 'ROL_CLIENT':
        return Roles.rolUser;
      case 'ROL_CONDUCTOR':
        return Roles.rolDriver;
      case 'ROL_GERENTE':
        return Roles.rolGerente;
      case 'ROL_SUPER_ADMIN':
        return Roles.rolAdmin;
      default:
        return Roles.rolUser;
    }
  }
}

/// Modelo para el rol desde Strapi
class StrapiRole {
  final int id;
  final String? documentId;
  final String nombreCatalogo;
  final String nemonicoCatalogo;

  StrapiRole({
    required this.id,
    this.documentId,
    required this.nombreCatalogo,
    required this.nemonicoCatalogo,
  });

  factory StrapiRole.fromJson(Map<String, dynamic> json) {
    return StrapiRole(
      id: json['id'] as int,
      documentId: json['documentId'] as String?,
      nombreCatalogo: json['nombre_catalogo'] as String? ?? '',
      nemonicoCatalogo: json['nemonico_catalogo'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'nombre_catalogo': nombreCatalogo,
      'nemonico_catalogo': nemonicoCatalogo,
    };
  }
}
