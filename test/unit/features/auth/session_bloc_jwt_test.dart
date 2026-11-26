// Prueba la inicializacion reactiva de SessionBloc (T12) contra JWTs reales
// (dart_jsonwebtoken, no strings armados a mano) guardados en un
// FlutterSecureStorage real (su MethodChannel mockeado con un mapa en
// memoria, mismo patron que T5/T11).

import 'package:auronix_app/app/core/bloc/session-bloc/session_bloc.dart';
import 'package:auronix_app/app/core/network/secure_storage_service.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

String _realJwt({
  String email = 'pasajero@test.com',
  List<String> roles = const ['PASAJERO'],
  Duration validFor = const Duration(minutes: 15),
}) {
  final jwt = JWT({'roles': roles}, subject: email);
  return jwt.sign(SecretKey('clave-de-prueba-no-real'), expiresIn: validFor);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> secureStorageBackingMap;
  late SecureStorageService secureStorage;

  setUp(() {
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
            default:
              return null;
          }
        });
    secureStorage = SecureStorageServiceImpl();
  });

  tearDown(() {
    const channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  SessionBloc buildBloc() => SessionBloc(
    _NoopAuthRepository(),
    RxSharedPreferences(_FakeSharedPreferences()),
    secureStorage: secureStorage,
  );

  test(
    'T12-C1 T12-C3 T12-C5: un JWT valido guardado en SecureStorageService autentica con el rol correcto',
    () async {
      await secureStorage.saveAccessToken(
        _realJwt(email: 'conductor@test.com', roles: const ['CONDUCTOR']),
      );

      final bloc = buildBloc();
      bloc.add(const CheckLoggedUserEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<SessionLoading>(),
          isA<SessionAuthenticated>()
              .having((s) => s.dataUser.email, 'email', 'conductor@test.com')
              .having((s) => s.dataUser.role, 'role', Roles.rolDriver),
        ]),
      );
      await bloc.close();
    },
  );

  test(
    'T12-C2 T12-C6: sin token guardado, no hay sesion que restaurar (Unauthenticated)',
    () async {
      final bloc = buildBloc();
      bloc.add(const CheckLoggedUserEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([isA<SessionLoading>(), isA<SessionUnauthenticated>()]),
      );
      await bloc.close();
    },
  );

  test(
    'T12-C4 T12-C6: un JWT expirado en SecureStorageService no autentica (Unauthenticated)',
    () async {
      await secureStorage.saveAccessToken(
        _realJwt(validFor: const Duration(seconds: -5)),
      );

      final bloc = buildBloc();
      bloc.add(const CheckLoggedUserEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([isA<SessionLoading>(), isA<SessionUnauthenticated>()]),
      );
      await bloc.close();
    },
  );
}

class _NoopAuthRepository implements AuthUnifiedRepository {
  @override
  Future<Either<Failure, AuthenticationCredentials?>>
  getClientSession() async => const Right(null);

  @override
  Future<Either<Failure, AuthenticationCredentials?>>
  getDriverSession() async => const Right(null);

  @override
  Future<dynamic> noSuchMethod(Invocation invocation) async => null;
}

class _FakeSharedPreferences implements SharedPreferences {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
