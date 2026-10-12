import 'package:auronix_app/features/verification/domain/models/driver_verification_status.dart';
import 'package:auronix_app/features/verification/domain/repositories/verification_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'verification_state.dart';

class VerificationCubit extends Cubit<VerificationState> {
  final VerificationRepository _repository;

  VerificationCubit(this._repository) : super(const VerificationInitial());

  Future<void> loadStatus() async {
    emit(const VerificationLoading());

    final result = await _repository.getVerificationStatus();

    result.fold(
      (failure) => emit(VerificationError(failure.message)),
      (status) => emit(VerificationLoaded(status: status)),
    );
  }

  Future<void> resendEmail() async {
    final current = state;
    if (current is! VerificationLoaded || current.isResending) return;

    emit(current.copyWith(isResending: true, resendMessage: null));

    final result = await _repository.resendVerificationEmail();

    result.fold(
      (failure) => emit(
        current.copyWith(isResending: false, resendMessage: failure.message),
      ),
      (_) => emit(
        current.copyWith(
          isResending: false,
          resendMessage: 'Correo reenviado. Revisa tu bandeja de entrada.',
        ),
      ),
    );
  }
}
