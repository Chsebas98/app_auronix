part of 'member_bloc.dart';

class MemberState extends Equatable {
  const MemberState({
    this.showRegisterForm = false,
    this.ciPassport = '',
    this.password = '',
    this.isRemember = false,
    this.registerForm = const InitialFormSubmitStatus(),
    this.loginForm = const InitialFormSubmitStatus(),
  });

  final bool showRegisterForm;
  final String ciPassport;
  final String password;
  final bool isRemember;
  final FormSubmitStatus registerForm;
  final FormSubmitStatus loginForm;

  ValidationFieldResult get isValidUsername =>
      FormValidators.validateCiPassport(ciPassport);

  ValidationFieldResult get isValidLoginPsw =>
      FormValidators.validateLoginPassword(password);

  MemberState copyWith({
    bool? showRegisterForm,
    String? ciPassport,
    String? password,
    bool? isRemember,
    FormSubmitStatus? registerForm,
    FormSubmitStatus? loginForm,
  }) {
    return MemberState(
      showRegisterForm: showRegisterForm ?? this.showRegisterForm,
      ciPassport: ciPassport ?? this.ciPassport,
      password: password ?? this.password,
      isRemember: isRemember ?? this.isRemember,
      registerForm: registerForm ?? this.registerForm,
      loginForm: loginForm ?? this.loginForm,
    );
  }

  @override
  List<Object> get props => [
    showRegisterForm,
    ciPassport,
    password,
    isRemember,
    registerForm,
    loginForm,
  ];
}
