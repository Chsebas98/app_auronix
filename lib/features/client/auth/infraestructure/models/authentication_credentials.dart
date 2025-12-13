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
  final bool isGoogleUser;

  const AuthenticationCredentials({
    required this.token,
    required this.role,
    required this.username,
    required this.firstName,
    required this.secondName,
    required this.lastName,
    required this.secondlastName,
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
      isGoogleUser = false;

  AuthenticationCredentials copyWith({
    String? token,
    Roles? role,
    String? username,
    String? firstName,
    dynamic secondName,
    String? lastName,
    String? secondlastName,
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
      isGoogleUser: isGoogleUser ?? this.isGoogleUser,
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'role': role.name,
    'username': username,
    'firstName': firstName,
    'secondName': secondName,
    'lastName': lastName,
    'secondlastName': secondlastName,
    'isGoogleUser': isGoogleUser,
  };

  @override
  String toString() => jsonEncode(toJson());
}
