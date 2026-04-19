part of 'auth_bloc.dart';

/// Monolithic form cubit that holds all auth-related form field values
/// and derived validation results. It replaces both [AuthState] and
/// [AuthConductorState] for the presentation layer.
class AuthFormCubit extends Cubit<AuthFormState> {
  final RxSharedPreferences _prefs;

  AuthFormCubit({required RxSharedPreferences prefs})
    : _prefs = prefs,
      super(const AuthFormState());

  // ──────────────────── Shared ────────────────────

  Future<void> initRemember({required bool isDriver}) async {
    final key = isDriver
        ? StaticVariables.rememberConductorKey
        : StaticVariables.rememberKey;
    final saved = await _prefs.getBool(key) ?? false;
    emit(state.copyWith(isRemember: saved));
  }

  void toggleRemember({required bool isDriver}) {
    final newValue = !state.isRemember;
    final key = isDriver
        ? StaticVariables.rememberConductorKey
        : StaticVariables.rememberKey;
    _prefs.setBool(key, newValue);
    emit(state.copyWith(isRemember: newValue));
  }

  void toggleShowRegister() {
    emit(state.copyWith(showRegisterForm: !state.showRegisterForm));
  }

  void reset() {
    emit(const AuthFormState());
  }

  // ──────────────────── Client fields ────────────────────

  void changeEmail(String email) => emit(state.copyWith(email: email));

  void changePassword(String password) =>
      emit(state.copyWith(password: password));

  // ──────────────────── Driver fields ────────────────────

  void changeCiPassport(String ciPassport) =>
      emit(state.copyWith(ciPassport: ciPassport.toUpperCase()));
}

/// Monolithic state for auth form fields and UI flags.
class AuthFormState extends Equatable {
  const AuthFormState({
    this.email = '',
    this.password = '',
    this.ciPassport = '',
    this.isRemember = false,
    this.showRegisterForm = false,
    this.showRegisterCompleteForm = false,
    this.showLoginConductorForm = false,
  });

  // Form fields
  final String email;
  final String password;
  final String ciPassport;

  // UI flags
  final bool isRemember;
  final bool showRegisterForm;
  final bool showRegisterCompleteForm;
  final bool showLoginConductorForm;

  // ──────────────────── Validation getters ────────────────────

  ValidationFieldResult get isValidLoginEmail =>
      FormValidators.validateLoginEmail(email);

  ValidationFieldResult get isValidRegisterEmail =>
      FormValidators.validateLoginEmail(email);

  ValidationFieldResult get isValidLoginPsw =>
      FormValidators.validateLoginPassword(password);

  ValidationFieldResult get isValidRegisterPsw =>
      FormValidators.validateRegisterPassword(password);

  ValidationFieldResult get isValidCiPassport =>
      FormValidators.validateCiPassport(ciPassport);

  // ──────────────────── copyWith ────────────────────

  AuthFormState copyWith({
    String? email,
    String? password,
    String? ciPassport,
    bool? isRemember,
    bool? showRegisterForm,
    bool? showRegisterCompleteForm,
    bool? showLoginConductorForm,
  }) {
    return AuthFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      ciPassport: ciPassport ?? this.ciPassport,
      isRemember: isRemember ?? this.isRemember,
      showRegisterForm: showRegisterForm ?? this.showRegisterForm,
      showRegisterCompleteForm:
          showRegisterCompleteForm ?? this.showRegisterCompleteForm,
      showLoginConductorForm:
          showLoginConductorForm ?? this.showLoginConductorForm,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    ciPassport,
    isRemember,
    showRegisterForm,
    showRegisterCompleteForm,
    showLoginConductorForm,
  ];
}
