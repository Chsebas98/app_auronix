import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LogoutUseCase {
  final AuthUnifiedRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.logout();
  }
}
