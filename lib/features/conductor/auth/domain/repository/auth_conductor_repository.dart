import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/client/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:dartz/dartz.dart';

abstract class AuthConductorRepository {
  Future<void> setRemember(bool value);
  Future<bool> getRemember();

  Future<Either<Failure, AuthenticationCredentials>> login({
    required String ciPassport,
    required String password,
    bool rememberMe = false,
  });

  Future<Either<Failure, AuthenticationCredentials>> register({
    required String ciPassport,
    required String password,
    required String email,
  });

  Future<Either<Failure, void>> logout();
}
