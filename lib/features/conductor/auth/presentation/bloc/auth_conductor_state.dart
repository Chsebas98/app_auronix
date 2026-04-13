part of 'auth_conductor_bloc.dart';

class AuthConductorState extends Equatable {
  const AuthConductorState({
    this.dialogRequest = const DialogRequest.empty(),
    this.showRegisterForm = false,
    this.ciPassport = '',
    this.password = '',
    this.isRemember = false,
    this.registerForm = const InitialFormSubmitStatus(),
    this.loginForm = const InitialFormSubmitStatus(),
    this.credentialsLogin = const AuthenticationCredentials.empty(),
  });
  final DialogRequest dialogRequest;
  final bool showRegisterForm;
  final String ciPassport;
  final String password;
  final bool isRemember;
  final FormSubmitStatus registerForm;
  final FormSubmitStatus loginForm;
  final AuthenticationCredentials credentialsLogin;

  ValidationFieldResult get isValidUsername =>
      FormValidators.validateCiPassport(ciPassport);

  ValidationFieldResult get isValidLoginPsw =>
      FormValidators.validateLoginPassword(password);

  AuthConductorState copyWith({
    DialogRequest? dialogRequest,
    bool? showRegisterForm,
    String? ciPassport,
    String? password,
    bool? isRemember,
    FormSubmitStatus? registerForm,
    FormSubmitStatus? loginForm,
    AuthenticationCredentials? credentialsLogin,
  }) {
    return AuthConductorState(
      dialogRequest: dialogRequest ?? this.dialogRequest,
      showRegisterForm: showRegisterForm ?? this.showRegisterForm,
      ciPassport: ciPassport ?? this.ciPassport,
      password: password ?? this.password,
      isRemember: isRemember ?? this.isRemember,
      registerForm: registerForm ?? this.registerForm,
      loginForm: loginForm ?? this.loginForm,
      credentialsLogin: credentialsLogin ?? this.credentialsLogin,
    );
  }

  @override
  List<Object> get props => [
    dialogRequest,
    showRegisterForm,
    ciPassport,
    password,
    isRemember,
    registerForm,
    loginForm,
    credentialsLogin,
  ];
}
