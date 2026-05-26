import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/client/domain/repositories/client_profile_repository.dart';
import 'package:dartz/dartz.dart';

class GetClientProfileUseCase {
  final ClientProfileRepository _repo;
  GetClientProfileUseCase(this._repo);

  Future<Either<Failure, AuthenticationCredentials>> call(int userId) =>
      _repo.getProfile(userId);
}
