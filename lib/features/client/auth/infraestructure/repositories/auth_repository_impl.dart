import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/client/auth/infraestructure/data/local/auth_local_services.dart';
import 'package:auronix_app/features/client/auth/infraestructure/data/remote/auth_remote_services.dart';
import 'package:auronix_app/features/client/auth/infraestructure/repositories/auth_repository.dart';
import 'package:auronix_app/features/features.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteServices remote;
  final AuthLocalServices local;
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
