import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class ChangeEmailUsecase {
  final AuthUnifiedRepository _repository;

  ChangeEmailUsecase(this._repository);

  Future<Either<Failure, void>> call(String newEmail) {
    return _repository.changeEmail(newEmail: newEmail);
  }
}
