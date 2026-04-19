import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:dartz/dartz.dart';

/// Restores the saved session for the given user type.
///
/// Returns `Right(null)` when no active session is found.
class RefreshTokenUseCase {
  final AuthUnifiedRepository _repository;

  RefreshTokenUseCase(this._repository);

  Future<Either<Failure, AuthenticationCredentials?>> forClient() {
    return _repository.getClientSession();
  }

  Future<Either<Failure, AuthenticationCredentials?>> forDriver() {
    return _repository.getDriverSession();
  }
}
