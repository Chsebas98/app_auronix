import 'dart:convert';

import 'package:auronix_app/core/core.dart';

class AuthenticationCredentials {
  final String tokenAccess;
  final String tokenRefresh;
  final Roles role;
  final String username;
  final String firstName;
  final dynamic secondName;
  final String lastName;
  final String secondlastName;
  final String email;
  final String photoUrl;
  final bool isGoogleUser;

  const AuthenticationCredentials({
    required this.tokenAccess,
    required this.tokenRefresh,
    required this.role,
    required this.username,
    required this.firstName,
    required this.secondName,
    required this.lastName,
    required this.secondlastName,
    required this.email,
    this.photoUrl = '',
    this.isGoogleUser = false,
  });

  const AuthenticationCredentials.empty()
    : tokenAccess = '',
      tokenRefresh = '',
      role = Roles.rolUser,
      username = '',
      firstName = '',
      secondName = null,
      lastName = '',
      secondlastName = '',
      email = '',
      photoUrl = '',
      isGoogleUser = false;

  factory AuthenticationCredentials.fromJson(Map<String, dynamic> json) {
    return AuthenticationCredentials(
      tokenAccess: json['tokenAccess'] ?? '',
      tokenRefresh: json['tokenRefresh'] ?? '',
      role: Roles.values.firstWhere(
        (role) => role.name == (json['role'] ?? 'rolUser'),
        orElse: () => Roles.rolUser,
      ),
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      secondName: json['secondName'],
      lastName: json['lastName'] ?? '',
      secondlastName: json['secondlastName'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      isGoogleUser: json['isGoogleUser'] ?? false,
    );
  }

  AuthenticationCredentials copyWith({
    String? tokenAccess,
    String? tokenRefresh,
    Roles? role,
    String? username,
    String? firstName,
    dynamic secondName,
    String? lastName,
    String? secondlastName,
    String? email,
    String? photoUrl,
    bool? isGoogleUser,
  }) {
    return AuthenticationCredentials(
      tokenAccess: tokenAccess ?? this.tokenAccess,
      tokenRefresh: tokenRefresh ?? this.tokenRefresh,
      role: role ?? this.role,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      lastName: lastName ?? this.lastName,
      secondlastName: secondlastName ?? this.secondlastName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isGoogleUser: isGoogleUser ?? this.isGoogleUser,
    );
  }

  Map<String, dynamic> toJson({bool includeToken = true}) => {
    'tokenAccess': tokenAccess,
    'tokenRefresh': tokenRefresh,
    'role': role.name,
    'username': username,
    'firstName': firstName,
    'secondName': secondName,
    'lastName': lastName,
    'secondlastName': secondlastName,
    'email': email,
    'photoUrl': photoUrl,
    'isGoogleUser': isGoogleUser,
  };

  Map<String, dynamic> toSafeJson({String mask = '***'}) => {
    ...toJson(),
    'tokenAccess': mask,
    'tokenRefresh': mask,
  };

  /// Para debug explícito (incluye token)
  String debugString() => jsonEncode(toJson());

  /// Para logs por defecto (NO incluye token)
  @override
  String toString() => jsonEncode(toSafeJson());
}
