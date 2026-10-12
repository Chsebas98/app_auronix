part of 'auth_bloc.dart';

sealed class AuthUnifiedEvent extends Equatable {
  const AuthUnifiedEvent();

  @override
  List<Object?> get props => [];
}

final class AuthLoginClientEvent extends AuthUnifiedEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const AuthLoginClientEvent({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

final class AuthLoginDriverEvent extends AuthUnifiedEvent {
  final String ciPassport;
  final String password;
  final bool rememberMe;

  const AuthLoginDriverEvent({
    required this.ciPassport,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [ciPassport, password, rememberMe];
}

final class AuthGoogleSignInEvent extends AuthUnifiedEvent {
  const AuthGoogleSignInEvent();
}

final class AuthVerifyRegisterClientEvent extends AuthUnifiedEvent {
  final String email;

  const AuthVerifyRegisterClientEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

final class AuthRegisterClientEvent extends AuthUnifiedEvent {
  final RegisterVerifyRequest verifyRequest;

  const AuthRegisterClientEvent({required this.verifyRequest});

  @override
  List<Object?> get props => [verifyRequest];
}

final class AuthVerifyRegisterOtpEvent extends AuthUnifiedEvent {
  final String email;
  final String code;

  const AuthVerifyRegisterOtpEvent({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

final class AuthResendRegisterOtpEvent extends AuthUnifiedEvent {
  final String email;

  const AuthResendRegisterOtpEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

final class AuthRegisterDriverEvent extends AuthUnifiedEvent {
  final String ciPassport;
  final String password;
  final String email;
  final String licenseNumber;
  final String licenseType;
  final String plateNumber;
  final String vehicleBrand;
  final String vehicleModel;
  final String vehicleYear;
  final DateTime birthDate;

  const AuthRegisterDriverEvent({
    required this.ciPassport,
    required this.password,
    required this.email,
    required this.birthDate,
    this.licenseNumber = '',
    this.licenseType = '',
    this.plateNumber = '',
    this.vehicleBrand = '',
    this.vehicleModel = '',
    this.vehicleYear = '',
  });

  @override
  List<Object?> get props => [
    ciPassport,
    password,
    email,
    licenseNumber,
    licenseType,
    plateNumber,
    vehicleBrand,
    vehicleModel,
    vehicleYear,
    birthDate,
  ];
}

final class AuthRestoreClientSessionEvent extends AuthUnifiedEvent {
  const AuthRestoreClientSessionEvent();
}

final class AuthRestoreDriverSessionEvent extends AuthUnifiedEvent {
  const AuthRestoreDriverSessionEvent();
}

final class AuthCompleteRegisterClientEvent extends AuthUnifiedEvent {
  final String name;
  final String email;
  final String gender;
  final String phone;
  final String password;
  final DateTime birthDate;

  const AuthCompleteRegisterClientEvent({
    required this.name,
    required this.email,
    required this.gender,
    required this.phone,
    required this.password,
    required this.birthDate,
  });

  @override
  List<Object?> get props => [name, email, gender, phone, password, birthDate];
}

final class AuthLogoutEvent extends AuthUnifiedEvent {
  const AuthLogoutEvent();
}
