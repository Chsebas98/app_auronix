import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/auth/domain/models/request/register_request.dart';
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

  Future<Either<Failure, void>> sendRegisterOtp({required String email});

  Future<Either<Failure, void>> verifyRegisterOtp({
    required String email,
    required String code,
  });

  Future<Either<Failure, AuthenticationCredentials>> registerClient(
    RegisterRequest registerData,
  );

  Future<Either<Failure, AuthenticationCredentials?>> getClientSession();

  //?Remote – Driver
  Future<Either<Failure, AuthenticationCredentials>> loginDriver({
    required String ciPassport,
    required String password,
    bool rememberMe = false,
  });

  Future<Either<Failure, AuthenticationCredentials>> registerDriver({
    required String ciPassport,
    required String password,
    required String email,
    String? licenseNumber,
    String? licenseType,
    String? plateNumber,
    String? vehicleBrand,
    String? vehicleModel,
    String? vehicleYear,
    DateTime? birthDate,
    String? terminosVersion,
    DateTime? terminosAceptadosEn,
  });

  Future<Either<Failure, AuthenticationCredentials?>> getDriverSession();

  //?Shared
  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> deleteAccount();

  Future<Either<Failure, void>> changeEmail({required String newEmail});

  Future<Either<Failure, void>> changePhone({required String newPhone});
}
