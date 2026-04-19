import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auronix_app/features/client/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:dartz/dartz.dart';

class GoogleLoginUseCase {
  final AuthUnifiedRepository _repository;

  GoogleLoginUseCase(this._repository);

  /// Step 1: Obtain Google credentials from the device.
  Future<Either<Failure, AuthenticationCredentials>> getGoogleCredentials() {
    return _repository.loginWithGoogle();
  }

  /// Step 2: Authenticate with the backend using the Google credentials.
  Future<Either<Failure, AuthenticationCredentials>> loginOrRegister(
    AuthenticationCredentials googleCreds,
  ) {
    return _repository.loginOrRegisterWithGoogle(googleCreds);
  }
}
