import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class ChangePhoneUsecase {
  final AuthUnifiedRepository _repository;

  ChangePhoneUsecase(this._repository);

  Future<Either<Failure, void>> call(String newPhone) {
    return _repository.changePhone(newPhone: newPhone);
  }
}
