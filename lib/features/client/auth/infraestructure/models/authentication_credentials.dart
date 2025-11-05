import 'package:auronix_app/core/core.dart';

class AuthenticationCredentials {
  final String token;
  final Roles role;
  final String username;
  final String firstName;
  final dynamic secondName;
  final String lastName;
  final String secondlastName;

  AuthenticationCredentials({
    required this.token,
    required this.role,
    required this.username,
    required this.firstName,
    required this.secondName,
    required this.lastName,
    required this.secondlastName,
  });
}
