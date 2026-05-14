import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthCompleteRegisterClientUsecase {
  final AuthUnifiedRepository _repository;

  AuthCompleteRegisterClientUsecase(this._repository);

  Future<Either<Failure, void>> call({
    required String name,
    required String email,
    required String gender,
    required String phone,
    required String password,
  }) {
    return _repository.completeRegisterClient();
  }
}
