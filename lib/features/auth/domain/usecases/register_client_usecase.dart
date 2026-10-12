import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_request.dart';
import 'package:dartz/dartz.dart';

class RegisterClientUseCase {
  final AuthUnifiedRepository _repository;

  RegisterClientUseCase(this._repository);

  /// Step 1: send the email OTP (docs/flow.md sección 11.1).
  Future<Either<Failure, void>> sendOtp(String email) {
    return _repository.sendRegisterOtp(email: email);
  }

  /// Step 2: verify the OTP code, unlocking the rest of the registration.
  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String code,
  }) {
    return _repository.verifyRegisterOtp(email: email, code: code);
  }

  /// Step 3: complete the registration with full user data.
  Future<Either<Failure, AuthenticationCredentials>> complete(
    RegisterRequest request,
  ) {
    return _repository.registerClient(request);
  }
}
