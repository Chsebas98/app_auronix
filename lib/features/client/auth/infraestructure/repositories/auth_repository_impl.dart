import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/features.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteServices remote;
  final AuthLocalServices local;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;
  // (Opcional) final LocalDatabase localDb;

  AuthRepositoryImpl({
    required this.remote,
    required this.local,
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
    );
    return creds;
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;

    await _googleSignIn.initialize();

    _googleInitialized = true;
  }

  @override
  Future<void> loginWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      final googleAccount = await _googleSignIn.authenticate();

      final auth = await googleAccount.authentication;

      debugPrint('Google Google Acount: $googleAccount');
      debugPrint('Google Auth Token: ${auth.idToken} $auth');
      // final credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth.,
      //   idToken: googleAuth.idToken,
      // );

      // await remote.loginWithGoogle();
    } catch (e) {
      debugPrintStack(
        label: 'Error en login con Google',
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await local.clearSession();
    // (Opcional) limpiar localDb tablas
  }

  @override
  Future<AuthenticationCredentials?> getSavedSession() async {
    final token = await local.getToken();
    if (token == null) return null;
    // (Opcional) validar token con backend
    final creds = AuthenticationCredentials(
      token: token,
      firstName: 'Sebas',
      lastName: 'Soberon',
      role: Roles.rolUser,
      secondName: 'Charly',
      secondlastName: 'Mateus',
      username: 'Chsebas',
    );
    return creds;
  }
}
