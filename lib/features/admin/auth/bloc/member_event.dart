part of 'member_bloc.dart';

sealed class MemberEvent extends Equatable {
  const MemberEvent();

  @override
  List<Object> get props => [];
}

class MemberInitRememberEvent extends MemberEvent {}

class MemberShowRegisterFormEvent extends MemberEvent {
  final bool showRegister;
  const MemberShowRegisterFormEvent({required this.showRegister});

  @override
  List<Object> get props => [showRegister];
}

class MemberChangeCiPassportEvent extends MemberEvent {
  final String ciPassport;
  const MemberChangeCiPassportEvent({required this.ciPassport});

  @override
  List<Object> get props => [ciPassport];
}

class MemberChangePasswordEvent extends MemberEvent {
  final String psw;
  const MemberChangePasswordEvent({required this.psw});

  @override
  List<Object> get props => [psw];
}

class MemberCheckedChangedEvent extends MemberEvent {}

class MemberRegisterSubmitEvent extends MemberEvent {
  final String email;
  final String psw;
  const MemberRegisterSubmitEvent({required this.email, required this.psw});

  @override
  List<Object> get props => [email, psw];
}

class MemberLoginSubmittedEvent extends MemberEvent {
  final String ciPassport;
  final String psw;
  const MemberLoginSubmittedEvent({
    required this.ciPassport,
    required this.psw,
  });

  @override
  List<Object> get props => [ciPassport, psw];
}
