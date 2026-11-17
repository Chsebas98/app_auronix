import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/client/data/models/profile_update_request_model.dart';
import 'package:dartz/dartz.dart';

abstract class ClientProfileRepository {
  Future<Either<Failure, AuthenticationCredentials>> getProfile(int userId);

  Future<Either<Failure, AuthenticationCredentials>> updateProfile({
    required int userId,
    required ProfileUpdateRequestModel data,
  });
}
