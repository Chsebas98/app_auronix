import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/features.dart';

abstract class AuthRepository {
  //?Local
  Future<void> setRemember(bool value);
  Future<bool> getRemember();

  //?Remote
  Future<ServiceResponse> login({
    required String email,
    required String password,
    AuthenticationCredentials isGoogle =
        const AuthenticationCredentials.empty(),
    bool rememberMe = false,
  });

  Future<AuthenticationCredentials> loginWithGoogle();

  /// NUEVO: Login/Registro con Google + Strapi
  Future<ServiceResponse> loginOrRegisterWithGoogle(
    AuthenticationCredentials googleCreds,
  );

  Future<ServiceResponse> verifyRegister(RegisterVerifyRequest registerData);

  Future<ServiceResponse> registerUser(RegisterRequest registerData);

  Future<AuthenticationCredentials?> getSavedSession();

  Future<void> logout();
}
