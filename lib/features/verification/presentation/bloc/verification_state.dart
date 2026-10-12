part of 'verification_cubit.dart';

sealed class VerificationState extends Equatable {
  const VerificationState();

  @override
  List<Object?> get props => [];
}

final class VerificationInitial extends VerificationState {
  const VerificationInitial();
}

final class VerificationLoading extends VerificationState {
  const VerificationLoading();
}

final class VerificationLoaded extends VerificationState {
  final DriverVerificationStatus status;
  final bool isResending;
  final String? resendMessage;

  const VerificationLoaded({
    required this.status,
    this.isResending = false,
    this.resendMessage,
  });

  VerificationLoaded copyWith({
    DriverVerificationStatus? status,
    bool? isResending,
    String? resendMessage,
  }) {
    return VerificationLoaded(
      status: status ?? this.status,
      isResending: isResending ?? this.isResending,
      resendMessage: resendMessage,
    );
  }

  @override
  List<Object?> get props => [status, isResending, resendMessage];
}

final class VerificationError extends VerificationState {
  final String message;

  const VerificationError(this.message);

  @override
  List<Object?> get props => [message];
}
