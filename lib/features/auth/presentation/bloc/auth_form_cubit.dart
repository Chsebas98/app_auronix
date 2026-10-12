import 'package:auronix_app/core/core.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class AuthFormCubit extends Cubit<AuthFormState> {
  final RxSharedPreferences _prefs;

  AuthFormCubit({required RxSharedPreferences prefs})
    : _prefs = prefs,
      super(const AuthFormState()) {
    _loadDraft();
  }

  static const _draftLicenseNumber = 'driver_draft_licenseNumber';
  static const _draftLicenseType = 'driver_draft_licenseType';
  static const _draftPlateNumber = 'driver_draft_plateNumber';
  static const _draftVehicleBrand = 'driver_draft_vehicleBrand';
  static const _draftVehicleModel = 'driver_draft_vehicleModel';
  static const _draftVehicleYear = 'driver_draft_vehicleYear';
  static const _draftBirthDate = 'driver_draft_birthDate';

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

  void toggleTerms() {
    emit(state.copyWith(termsAccepted: !state.termsAccepted));
  }

  void setBirthDate(DateTime date) {
    emit(state.copyWith(birthDate: date));
    _prefs.setString(_draftBirthDate, date.toIso8601String());
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

  void showDriverLogin() => emit(state.copyWith(showLoginConductorForm: true));
  void hideDriverLogin() => emit(state.copyWith(showLoginConductorForm: false));

  // ──────────────────── Driver registration fields ────────────────────

  void changeLicenseNumber(String v) {
    emit(state.copyWith(licenseNumber: v));
    saveDraft();
  }

  void changeLicenseType(String v) {
    emit(state.copyWith(licenseType: v));
    saveDraft();
  }

  void changePlateNumber(String v) {
    emit(state.copyWith(plateNumber: v.toUpperCase()));
    saveDraft();
  }

  void changeVehicleBrand(String v) {
    emit(state.copyWith(vehicleBrand: v));
    saveDraft();
  }

  void changeVehicleModel(String v) {
    emit(state.copyWith(vehicleModel: v));
    saveDraft();
  }

  void changeVehicleYear(String v) {
    emit(state.copyWith(vehicleYear: v));
    saveDraft();
  }

  Future<void> saveDraft() async {
    await Future.wait([
      _prefs.setString(_draftLicenseNumber, state.licenseNumber),
      _prefs.setString(_draftLicenseType, state.licenseType),
      _prefs.setString(_draftPlateNumber, state.plateNumber),
      _prefs.setString(_draftVehicleBrand, state.vehicleBrand),
      _prefs.setString(_draftVehicleModel, state.vehicleModel),
      _prefs.setString(_draftVehicleYear, state.vehicleYear),
    ]);
  }

  Future<void> _loadDraft() async {
    final results = await Future.wait([
      _prefs.getString(_draftLicenseNumber),
      _prefs.getString(_draftLicenseType),
      _prefs.getString(_draftPlateNumber),
      _prefs.getString(_draftVehicleBrand),
      _prefs.getString(_draftVehicleModel),
      _prefs.getString(_draftVehicleYear),
      _prefs.getString(_draftBirthDate),
    ]);
    final savedBirthDate = results[6];
    emit(
      state.copyWith(
        licenseNumber: results[0] ?? '',
        licenseType: results[1] ?? '',
        plateNumber: results[2] ?? '',
        vehicleBrand: results[3] ?? '',
        vehicleModel: results[4] ?? '',
        vehicleYear: results[5] ?? '',
        birthDate: savedBirthDate != null
            ? DateTime.tryParse(savedBirthDate)
            : null,
      ),
    );
  }
}

class AuthFormState extends Equatable {
  const AuthFormState({
    this.email = '',
    this.password = '',
    this.ciPassport = '',
    this.isRemember = false,
    this.showRegisterForm = false,
    this.showRegisterCompleteForm = false,
    this.showLoginConductorForm = false,
    this.termsAccepted = false,
    this.birthDate,
    this.licenseNumber = '',
    this.licenseType = '',
    this.plateNumber = '',
    this.vehicleBrand = '',
    this.vehicleModel = '',
    this.vehicleYear = '',
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
  final bool termsAccepted;
  final DateTime? birthDate;

  // Driver registration fields
  final String licenseNumber;
  final String licenseType;
  final String plateNumber;
  final String vehicleBrand;
  final String vehicleModel;
  final String vehicleYear;

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
    bool? termsAccepted,
    DateTime? birthDate,
    String? licenseNumber,
    String? licenseType,
    String? plateNumber,
    String? vehicleBrand,
    String? vehicleModel,
    String? vehicleYear,
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
      termsAccepted: termsAccepted ?? this.termsAccepted,
      birthDate: birthDate ?? this.birthDate,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseType: licenseType ?? this.licenseType,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleBrand: vehicleBrand ?? this.vehicleBrand,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleYear: vehicleYear ?? this.vehicleYear,
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
    termsAccepted,
    birthDate,
    licenseNumber,
    licenseType,
    plateNumber,
    vehicleBrand,
    vehicleModel,
    vehicleYear,
  ];
}
