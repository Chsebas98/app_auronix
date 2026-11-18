/// DTO del body real de `POST /api/v1/auth/login` (`LoginRequestDto`):
/// solo email y password.
class LoginRequestModel {
  final String email;
  final String password;

  const LoginRequestModel({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
