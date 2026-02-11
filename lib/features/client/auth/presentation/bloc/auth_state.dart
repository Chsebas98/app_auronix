part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState({
    this.dialogRequest = const DialogRequest.empty(),
    this.showRegisterForm = false,
    this.email = '',
    this.password = '',
    this.isRemember = false,
    this.registerForm = const InitialFormSubmitStatus(),
    this.completeRegisterForm = const InitialFormSubmitStatus(),
    this.loginForm = const InitialFormSubmitStatus(),
    this.credentialsLogin = const AuthenticationCredentials.empty(),
    //register
    this.showRegisterCompleteForm = false,
  });

  //generales
  final DialogRequest dialogRequest;

  //auth
  final bool showRegisterForm;
  final String email;
  final String password;
  final bool isRemember;
  final FormSubmitStatus registerForm;
  final FormSubmitStatus completeRegisterForm;
  final FormSubmitStatus loginForm;
  final AuthenticationCredentials credentialsLogin;

  //register
  final bool showRegisterCompleteForm;

  //validaciones
  ValidationFieldResult get isValidLoginEmail =>
      FormValidators.validateLoginEmail(email);

  ValidationFieldResult get isValidRegisterEmail =>
      FormValidators.validateLoginEmail(email);

  ValidationFieldResult get isValidLoginPsw =>
      FormValidators.validateLoginPassword(password);

  ValidationFieldResult get isValidRegisterPsw =>
      FormValidators.validateRegisterPassword(password);

  AuthState copyWith({
    DialogRequest? dialogRequest,
    bool? showRegisterForm,
    String? email,
    String? password,
    bool? isRemember,
    FormSubmitStatus? registerForm,
    FormSubmitStatus? completeRegisterForm,
    FormSubmitStatus? loginForm,
    AuthenticationCredentials? credentialsLogin,
    //register
    bool? showRegisterCompleteForm,
  }) {
    return AuthState(
      dialogRequest: dialogRequest ?? this.dialogRequest,
      showRegisterForm: showRegisterForm ?? this.showRegisterForm,
      email: email ?? this.email,
      password: password ?? this.password,
      isRemember: isRemember ?? this.isRemember,
      registerForm: registerForm ?? this.registerForm,
      completeRegisterForm: completeRegisterForm ?? this.completeRegisterForm,
      loginForm: loginForm ?? this.loginForm,
      credentialsLogin: credentialsLogin ?? this.credentialsLogin,
      //register
      showRegisterCompleteForm:
          showRegisterCompleteForm ?? this.showRegisterCompleteForm,
    );
  }

  @override
  List<Object> get props => [
    dialogRequest,
    showRegisterForm,
    email,
    password,
    isRemember,
    registerForm,
    completeRegisterForm,
    loginForm,
    credentialsLogin,
    //register
    showRegisterCompleteForm,
  ];
}
