// Prueba el login/registro reales de T11 (AuthRemoteDatasource.login/register
// + AuthRepositoryUnifiedImpl.loginWithBackend/registerWithBackend) contra un
// servidor HTTP real local (dart:io), no un mock de Dio: se levanta
// /api/v1/auth/{login,register} tal como los expone AuthController en
// micro-auronix, y se usa flutter_secure_storage real (su MethodChannel
// mockeado con un mapa en memoria, mismo patron que T5).

import 'dart:convert';
import 'dart:io';

import 'package:auronix_app/app/core/network/secure_storage_service.dart';
import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/auth_local_db_datasource.dart';
import 'package:auronix_app/app/database/db_constants.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/app/environments/flavors/env_base_config.dart';
import 'package:auronix_app/core/errors/failure.dart';
import 'package:auronix_app/features/auth/data/datasources/auth_local_services.dart';
import 'package:auronix_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:auronix_app/features/auth/data/models/login_request_model.dart';
import 'package:auronix_app/features/auth/data/models/register_request_model.dart';
import 'package:auronix_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:auronix_app/features/auth/domain/models/user_data.dart';
import 'package:auronix_app/features/auth/domain/models/user_role.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _FakeEnvConfig implements EnvBaseConfig {
  _FakeEnvConfig(this.apiBaseUrl);
  @override
  final String apiBaseUrl;
  @override
  String get googleMapsApiKey => '';
  @override
  String get tokenKey => '';
  @override
  RSAPublicKey get publicKey => throw UnimplementedError();
}

/// Servidor HTTP real minimo: responde /auth/login y /auth/register segun
/// [loginStatusCode]/[loginBody] configurados por el test.
class _FakeAuthServer {
  HttpServer? _server;
  int loginStatusCode = 200;
  Map<String, dynamic> loginBody = {};
  int registerStatusCode = 201;
  Map<String, dynamic> registerBody = {};
  Map<String, dynamic>? lastLoginRequest;
  Map<String, dynamic>? lastRegisterRequest;

  int get port => _server!.port;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((request) async {
      final bodyStr = await utf8.decoder.bind(request).join();
      final json = bodyStr.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(bodyStr) as Map<String, dynamic>;

      if (request.uri.path == '/api/v1/auth/login') {
        lastLoginRequest = json;
        request.response.statusCode = loginStatusCode;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(loginBody));
      } else if (request.uri.path == '/api/v1/auth/register') {
        lastRegisterRequest = json;
        request.response.statusCode = registerStatusCode;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(registerBody));
      } else {
        request.response.statusCode = 404;
      }
      await request.response.close();
    });
  }

  Future<void> close() async => _server?.close(force: true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  // flutter_test intercepta HttpClient por defecto y devuelve 400 sin tocar
  // la red real (para evitar llamadas reales accidentales en widget tests).
  // Aqui el servidor local SI es el punto de la prueba, asi que se desactiva.
  HttpOverrides.global = null;

  late _FakeAuthServer server;
  late AuthRemoteDatasource datasource;
  late AuthRepositoryUnifiedImpl repository;
  late Map<String, String> secureStorageBackingMap;

  setUp(() async {
    server = _FakeAuthServer();
    await server.start();
    Environment().config = _FakeEnvConfig(
      'http://127.0.0.1:${server.port}/api/v1',
    );

    datasource = AuthRemoteDatasource(dio: Dio());

    secureStorageBackingMap = {};
    const channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'write':
              secureStorageBackingMap[call.arguments['key'] as String] =
                  call.arguments['value'] as String;
              return null;
            case 'read':
              return secureStorageBackingMap[call.arguments['key'] as String];
            case 'delete':
              secureStorageBackingMap.remove(call.arguments['key'] as String);
              return null;
            default:
              return null;
          }
        });

    repository = AuthRepositoryUnifiedImpl(
      remote: datasource,
      clientDb: AuthLocalDbDataSource(
        AppDatabase.instance,
        userType: DbConstants.userTypeClient,
      ),
      driverDb: AuthLocalDbDataSource(
        AppDatabase.instance,
        userType: DbConstants.userTypeDriver,
      ),
      local: AuthLocalServices(RxSharedPreferences(_FakeSharedPreferences())),
      prefs: RxSharedPreferences(_FakeSharedPreferences()),
      secureStorage: SecureStorageServiceImpl(),
    );
  });

  tearDown(() async {
    await server.close();
    const channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('AuthRemoteDatasource (backend real)', () {
    test(
      'T11-C1 T11-C3 T11-C5: login exitoso devuelve el JWT real del backend',
      () async {
        server.loginBody = {
          'userId': 10,
          'email': 'pasajero@test.com',
          'roles': ['PASAJERO'],
          'accessToken': 'jwt-access-real',
          'refreshToken': 'jwt-refresh-real',
        };

        final response = await datasource.login(
          const LoginRequestModel(
            email: 'pasajero@test.com',
            password: 'secreta',
          ),
        );

        expect(response.accessToken, 'jwt-access-real');
        expect(response.role, UserRole.pasajero);
        expect(server.lastLoginRequest, {
          'email': 'pasajero@test.com',
          'password': 'secreta',
        });
      },
    );

    test(
      'T11-C4: un 401 del backend se mapea a AuthFailure sin exponer datos sensibles',
      () async {
        server.loginStatusCode = 401;
        server.loginBody = {'message': 'Credenciales inválidas'};

        await expectLater(
          datasource.login(
            const LoginRequestModel(email: 'x@test.com', password: 'mal'),
          ),
          throwsA(
            isA<AuthRequestException>().having(
              (e) => e.failure,
              'failure',
              isA<AuthFailure>(),
            ),
          ),
        );
      },
    );

    test(
      'T11-C4: un 403 del backend tambien se mapea a una falla tipada',
      () async {
        server.loginStatusCode = 403;
        server.loginBody = {'message': 'Prohibido'};

        await expectLater(
          datasource.login(
            const LoginRequestModel(email: 'x@test.com', password: 'y'),
          ),
          throwsA(isA<AuthRequestException>()),
        );
      },
    );
  });

  group('AuthRepositoryUnifiedImpl.loginWithBackend (T11)', () {
    test(
      'T11-C2 T11-C6: el JWT recibido se persiste en Flutter Secure Storage',
      () async {
        server.loginBody = {
          'userId': 7,
          'email': 'conductor@test.com',
          'roles': ['CONDUCTOR'],
          'accessToken': 'persisted-access',
          'refreshToken': 'persisted-refresh',
        };

        final result = await repository.loginWithBackend(
          email: 'conductor@test.com',
          password: 'secreta',
        );

        expect(
          result,
          Right<Failure, UserData>(
            const UserData(
              id: 7,
              email: 'conductor@test.com',
              role: UserRole.conductor,
            ),
          ),
        );
        expect(
          secureStorageBackingMap[SecureStorageServiceImpl.keyAccessToken],
          'persisted-access',
        );
        expect(
          secureStorageBackingMap[SecureStorageServiceImpl.keyRefreshToken],
          'persisted-refresh',
        );
      },
    );

    test(
      'T11-C4: credenciales invalidas no tocan el almacenamiento seguro',
      () async {
        server.loginStatusCode = 401;
        server.loginBody = {'message': 'Credenciales inválidas'};

        final result = await repository.loginWithBackend(
          email: 'x@test.com',
          password: 'mal',
        );

        expect(result.isLeft(), isTrue);
        expect(secureStorageBackingMap, isEmpty);
      },
    );
  });

  group('AuthRepositoryUnifiedImpl.registerWithBackend (T11)', () {
    test(
      'registra y luego inicia sesion automaticamente (el registro no trae tokens)',
      () async {
        server.registerBody = {
          'userId': 99,
          'email': 'nuevo@test.com',
          'tipo': 'PASAJERO',
          'profileId': 1,
        };
        server.loginBody = {
          'userId': 99,
          'email': 'nuevo@test.com',
          'roles': ['PASAJERO'],
          'accessToken': 'post-register-access',
          'refreshToken': 'post-register-refresh',
        };

        final result = await repository.registerWithBackend(
          const RegisterRequestModel(
            email: 'nuevo@test.com',
            password: 'secreta',
            firstName: 'Nuevo',
            lastName: 'Usuario',
            cedula: '0999999999',
            role: UserRole.pasajero,
          ),
        );

        expect(result.isRight(), isTrue);
        expect(server.lastRegisterRequest?['tipo'], 'PASAJERO');
        expect(
          secureStorageBackingMap[SecureStorageServiceImpl.keyAccessToken],
          'post-register-access',
        );
      },
    );
  });
}

class _FakeSharedPreferences implements SharedPreferences {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
