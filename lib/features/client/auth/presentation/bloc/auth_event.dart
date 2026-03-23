part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class InitRememberEvent extends AuthEvent {}

class ResetFormStateEvent extends AuthEvent {}

class ShowRegisterFormEvent extends AuthEvent {
  final bool showRegister;
  const ShowRegisterFormEvent({required this.showRegister});

  @override
  List<Object> get props => [showRegister];
}

class ChangeEmailEvent extends AuthEvent {
  final String email;
  const ChangeEmailEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class ChangePasswordEvent extends AuthEvent {
  final String psw;
  const ChangePasswordEvent({required this.psw});

  @override
  List<Object> get props => [psw];
}

class CheckedChangedEvent extends AuthEvent {}

class RegisterSubmitEvent extends AuthEvent {
  final String email;
  final String psw;
  final Roles rol;
  const RegisterSubmitEvent({
    required this.email,
    required this.psw,
    this.rol = Roles.rolUser,
  });

  @override
  List<Object> get props => [email, psw];
}

class CompleteRegisterSubmitEvent extends AuthEvent {
  final String name;
  final String email;
  final String gender;
  final String phone;
  final String psw;
  final Roles rol;
  const CompleteRegisterSubmitEvent({
    required this.name,
    required this.email,
    required this.gender,
    required this.psw,
    required this.phone,
    this.rol = Roles.rolUser,
  });

  @override
  List<Object> get props => [name, email, gender, phone, psw, rol];
}

class LoginSubmittedEvent extends AuthEvent {
  final String email;
  final String psw;
  const LoginSubmittedEvent({required this.email, required this.psw});

  @override
  List<Object> get props => [email, psw];
}

class GoogleSignInRequestedEvent extends AuthEvent {}

class ConductorSignInRequestedEvent extends AuthEvent {}
