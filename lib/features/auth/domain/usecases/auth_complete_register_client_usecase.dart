import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_request.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthCompleteRegisterClientUsecase {
  final AuthUnifiedRepository _repository;

  AuthCompleteRegisterClientUsecase(this._repository);

  /// `gender` se recolecta en el formulario pero no se envía: no hay un
  /// campo `genero` confirmado en docs/database.md para `usuario` — ver
  /// docs/requerimientos_backend.md sección 9.
  Future<Either<Failure, AuthenticationCredentials>> call({
    required String name,
    required String email,
    required String gender,
    required String phone,
    required String password,
    required DateTime birthDate,
  }) {
    return _repository.registerClient(
      RegisterRequest(
        email: email,
        password: password,
        username: email,
        nombre1: name,
        nombre2: '',
        ape1: '',
        ape2: '',
        telefono: phone,
        fechaNacimiento: birthDate,
        terminosVersion: StaticVariables.currentTerminosVersion,
        terminosAceptadosEn: DateTime.now(),
      ),
    );
  }
}
