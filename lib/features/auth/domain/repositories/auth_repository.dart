import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/data/models/register_request_model.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_driver_request.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_request.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_verify_request.dart';
import 'package:auronix_app/features/auth/domain/models/user_data.dart';
import 'package:dartz/dartz.dart';

/// Unified authentication repository used by both clients and drivers.
abstract class AuthUnifiedRepository {
  //?Local
  Future<void> setRemember(bool value);
  Future<bool> getRemember();

  //?Remote – Client
  Future<Either<Failure, AuthenticationCredentials>> loginClient({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<Either<Failure, AuthenticationCredentials>> loginWithGoogle();

  Future<Either<Failure, AuthenticationCredentials>> loginOrRegisterWithGoogle(
    AuthenticationCredentials googleCreds,
  );

  Future<Either<Failure, void>> verifyRegister(
    RegisterVerifyRequest registerData,
  );

  Future<Either<Failure, AuthenticationCredentials>> registerClient(
    RegisterRequest registerData,
  );

  Future<Either<Failure, AuthenticationCredentials?>> getClientSession();

  Future<Either<Failure, void>> completeRegisterClient();

  //?Remote – Driver
  Future<Either<Failure, AuthenticationCredentials>> loginDriver({
    required String ciPassport,
    required String password,
    bool rememberMe = false,
  });

  Future<Either<Failure, AuthenticationCredentials>> registerDriver(
    RegisterDriverRequest data,
  );

  Future<Either<Failure, AuthenticationCredentials?>> getDriverSession();

  //?Shared
  Future<Either<Failure, void>> logout();

  //?Backend real (T11): /api/v1/auth/{login,register}, persistido en
  //?SecureStorageService (T5) en vez de AuthLocalDbDataSource.
  Future<Either<Failure, UserData>> loginWithBackend({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserData>> registerWithBackend(
    RegisterRequestModel data,
  );
}
