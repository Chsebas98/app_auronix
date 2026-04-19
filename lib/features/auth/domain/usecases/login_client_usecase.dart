import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auronix_app/features/client/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:dartz/dartz.dart';

class LoginClientUseCase {
  final AuthUnifiedRepository _repository;

  LoginClientUseCase(this._repository);

  Future<Either<Failure, AuthenticationCredentials>> call({
    required String email,
    required String password,
    bool rememberMe = false,
  }) {
    return _repository.loginClient(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
  }
}
