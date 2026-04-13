import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/client/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/client/auth/domain/models/request/register_request.dart';
import 'package:auronix_app/features/client/auth/domain/models/request/register_verify_request.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  //?Local
  Future<void> setRemember(bool value);
  Future<bool> getRemember();

  //?Remote
  Future<Either<Failure, AuthenticationCredentials>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<Either<Failure, AuthenticationCredentials>> loginWithGoogle();

  Future<Either<Failure, AuthenticationCredentials>> loginOrRegisterWithGoogle(
    AuthenticationCredentials googleCreds,
  );

  Future<Either<Failure, void>> verifyRegister(
    RegisterVerifyRequest registerData,
  );

  Future<Either<Failure, AuthenticationCredentials>> registerUser(
    RegisterRequest registerData,
  );

  Future<Either<Failure, AuthenticationCredentials?>> getSavedSession();

  Future<Either<Failure, void>> logout();
}
