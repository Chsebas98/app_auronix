import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_driver_request.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class RegisterDriverUseCase {
  final AuthUnifiedRepository _repository;

  RegisterDriverUseCase(this._repository);

  Future<Either<Failure, AuthenticationCredentials>> call(
    RegisterDriverRequest data,
  ) {
    return _repository.registerDriver(data);
  }
}
