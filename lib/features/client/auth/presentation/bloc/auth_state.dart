part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState({
    this.showRegisterForm = false,
    this.email = '',
    this.password = '',
    this.isRemember = false,
    this.registerForm = const InitialFormSubmitStatus(),
    this.loginForm = const InitialFormSubmitStatus(),
    //register
    this.showRegisterCompleteForm = false,
  });

  //auth
  final bool showRegisterForm;
  final String email;
  final String password;
  final bool isRemember;
  final FormSubmitStatus registerForm;
  final FormSubmitStatus loginForm;

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
    bool? showRegisterForm,
    String? email,
    String? password,
    bool? isRemember,
    FormSubmitStatus? registerForm,
    FormSubmitStatus? loginForm,
    //register
    bool? showRegisterCompleteForm,
  }) {
    return AuthState(
      showRegisterForm: showRegisterForm ?? this.showRegisterForm,
      email: email ?? this.email,
      password: password ?? this.password,
      isRemember: isRemember ?? this.isRemember,
      registerForm: registerForm ?? this.registerForm,
      loginForm: loginForm ?? this.loginForm,
      //register
      showRegisterCompleteForm:
          showRegisterCompleteForm ?? this.showRegisterCompleteForm,
    );
  }

  @override
  List<Object> get props => [
    showRegisterForm,
    email,
    password,
    isRemember,
    registerForm,
    loginForm,
    //register
    showRegisterCompleteForm,
  ];
}
