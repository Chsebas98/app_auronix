import 'package:auronix_app/app/database/auth_local_db_datasource.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/features.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteServices remote;
  final AuthLocalServices local;
  final AuthLocalDbDataSource localDb;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;
  // (Opcional) final LocalDatabase localDb;

  AuthRepositoryImpl({
    required this.remote,
    required this.local,
    required this.localDb,
    // required this.localDb,
  });

  //?LOCAL
  @override
  Future<void> setRemember(bool value) async {
    await local.setRememberMe(value);
  }

  @override
  Future<bool> getRemember() async {
    return await local.getRememberMe();
  }

  //?REMOTAS

  @override
  Future<AuthenticationCredentials> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final response = await remote.loginUser(email: email, password: password);
    await local.saveToken(response['token'] ?? 'hola');
    await local.setRememberMe(true);
    final creds = AuthenticationCredentials(
      token: response['token'] ?? 'hola',
      firstName: 'Sebas',
      lastName: 'Soberon',
      role: Roles.rolUser,
      secondName: 'Charly',
      secondlastName: 'Mateus',
      username: 'Chsebas',
      email: email,
      photoUrl: '',
    );

    await localDb.saveUser(creds);

    return creds;
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;

    await _googleSignIn.initialize();

    _googleInitialized = true;
  }

  @override
  Future<AuthenticationCredentials> loginWithGoogle() async {
    await _ensureGoogleInitialized();

    final googleAccount = await _googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth = googleAccount.authentication;

    // debugPrint('Google Google Acount: $googleAccount');
    // debugPrint('Google Auth Token: $googleAuth');

    if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
      throw GoogleSignInException(
        code: GoogleSignInExceptionCode.unknownError,
        description: 'El token no se obtuvo correctamente',
      );
    }
    final (firstName, lastName) = ResponseHelpers.compoundNamesGoogle(
      googleAccount.displayName ?? '',
    );

    final authModel = AuthenticationCredentials(
      token: googleAuth.idToken!,
      role: Roles.rolUser,
      username: '',
      firstName: firstName,
      secondName: '',
      lastName: lastName ?? '',
      secondlastName: '',
      email: googleAccount.email,
      photoUrl: googleAccount.photoUrl ?? '',
      isGoogleUser: true,
    );
    final exists = await localDb.readUser();
    debugPrint('Usuario existe en BD local: ${exists}');

    await localDb.saveUser(authModel);

    return authModel;
  }

  @override
  Future<void> logout() async {
    localDb.clear();
    await local.clearSession();
  }

  Future<bool> hasSavedUser() async {
    final user = await localDb.readUser();
    return user != null;
  }

  @override
  Future<AuthenticationCredentials?> getSavedSession() {
    return localDb.readUser();
  }
}
