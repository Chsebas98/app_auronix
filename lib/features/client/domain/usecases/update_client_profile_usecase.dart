import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/client/data/models/profile_update_request_model.dart';
import 'package:auronix_app/features/client/domain/repositories/client_profile_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateClientProfileUseCase {
  final ClientProfileRepository _repo;
  UpdateClientProfileUseCase(this._repo);

  Future<Either<Failure, AuthenticationCredentials>> call({
    required int userId,
    required ProfileUpdateRequestModel data,
  }) =>
      _repo.updateProfile(userId: userId, data: data);
}
