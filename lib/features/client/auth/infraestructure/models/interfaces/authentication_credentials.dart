import 'dart:convert';

import 'package:auronix_app/core/core.dart';

class AuthenticationCredentials {
  final String token;
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
    required this.token,
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
    : token = '',
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
      token: json['token'] ?? '',
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
    String? token,
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
      token: token ?? this.token,
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
    'token': token,
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
    'token': mask,
  };

  /// Para debug explícito (incluye token)
  String debugString() => jsonEncode(toJson());

  /// Para logs por defecto (NO incluye token)
  @override
  String toString() => jsonEncode(toSafeJson());
}
