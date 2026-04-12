part of 'auth_conductor_bloc.dart';

sealed class AuthConductorEvent extends Equatable {
  const AuthConductorEvent();

  @override
  List<Object> get props => [];
}

class ConductorInitRememberEvent extends AuthConductorEvent {}

class ConductorResetFormStateEvent extends AuthConductorEvent {}

class ConductorShowRegisterFormEvent extends AuthConductorEvent {
  final bool showRegister;
  const ConductorShowRegisterFormEvent({required this.showRegister});

  @override
  List<Object> get props => [showRegister];
}

class ConductorChangeCiPassportEvent extends AuthConductorEvent {
  final String ciPassport;
  const ConductorChangeCiPassportEvent({required this.ciPassport});

  @override
  List<Object> get props => [ciPassport];
}

class ConductorChangePasswordEvent extends AuthConductorEvent {
  final String psw;
  const ConductorChangePasswordEvent({required this.psw});

  @override
  List<Object> get props => [psw];
}

class ConductorCheckedChangedEvent extends AuthConductorEvent {}

class ConductorRegisterSubmitEvent extends AuthConductorEvent {
  final String email;
  final String ciPassport;
  final String psw;
  const ConductorRegisterSubmitEvent({
    required this.email,
    required this.ciPassport,
    required this.psw,
  });

  @override
  List<Object> get props => [email, ciPassport, psw];
}

class ConductorLoginSubmittedEvent extends AuthConductorEvent {
  final String ciPassport;
  final String psw;
  const ConductorLoginSubmittedEvent({
    required this.ciPassport,
    required this.psw,
  });

  @override
  List<Object> get props => [ciPassport, psw];
}
