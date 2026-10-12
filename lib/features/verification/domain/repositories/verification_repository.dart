import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/verification/domain/models/driver_verification_status.dart';
import 'package:dartz/dartz.dart';

abstract class VerificationRepository {
  Future<Either<Failure, DriverVerificationStatus>> getVerificationStatus();

  Future<Either<Failure, void>> resendVerificationEmail();
}
