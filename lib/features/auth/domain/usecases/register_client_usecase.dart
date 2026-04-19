import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auronix_app/features/client/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/client/auth/domain/models/request/register_request.dart';
import 'package:auronix_app/features/client/auth/domain/models/request/register_verify_request.dart';
import 'package:dartz/dartz.dart';

class RegisterClientUseCase {
  final AuthUnifiedRepository _repository;

  RegisterClientUseCase(this._repository);

  /// Step 1: Verify email availability and send OTP / verification email.
  Future<Either<Failure, void>> verify(RegisterVerifyRequest request) {
    return _repository.verifyRegister(request);
  }

  /// Step 2: Complete the registration with full user data.
  Future<Either<Failure, AuthenticationCredentials>> complete(
    RegisterRequest request,
  ) {
    return _repository.registerClient(request);
  }
}
