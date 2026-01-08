import 'package:auronix_app/features/features.dart';

abstract class AuthRepository {
  //?Local
  Future<void> setRemember(bool value);
  Future<bool> getRemember();
  //?Remote
  Future<AuthenticationCredentials> login({
    required String email,
    required String password,
    AuthenticationCredentials isGoogle =
        const AuthenticationCredentials.empty(),
    bool rememberMe = false,
  });

  Future<AuthenticationCredentials> loginWithGoogle();

  Future<AuthenticationCredentials?> getSavedSession();

  Future<void> logout();
}
