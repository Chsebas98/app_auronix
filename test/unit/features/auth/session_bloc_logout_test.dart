// Prueba el logout de SessionBloc (T16) contra un SecureStorageService real
// (FlutterSecureStorage con su MethodChannel mockeado con un mapa en
// memoria, mismo patron que session_bloc_jwt_test.dart, T12).
//
// La redireccion inmediata a login (T16-C6) ya esta cubierta a nivel de
// router por role_redirect_guard_test.dart (T15): SessionUnauthenticated en
// una ruta protegida siempre redirige a /auth. Aqui solo se prueba el
// contrato del que depende ese guard — que logout efectivamente deja el
// Bloc en SessionUnauthenticated — y el borrado real de los tokens.

import 'package:auronix_app/app/core/bloc/session-bloc/session_bloc.dart';
import 'package:auronix_app/app/core/network/secure_storage_service.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

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
            case 'delete':
              secureStorageBackingMap.remove(call.arguments['key'] as String);
              return null;
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
    'T16-C5: el logout elimina por completo los tokens de SecureStorageService',
    () async {
      await secureStorage.saveAccessToken('token-de-acceso');
      await secureStorage.saveRefreshToken('token-de-refresco');

      final bloc = buildBloc();
      bloc.add(const LoggoutUserEvent());
      await expectLater(
        bloc.stream,
        emitsInOrder([isA<SessionLoading>(), isA<SessionUnauthenticated>()]),
      );
      await bloc.close();

      final access = (await secureStorage.getAccessToken()).fold(
        (_) => 'ERROR',
        (t) => t,
      );
      final refresh = (await secureStorage.getRefreshToken()).fold(
        (_) => 'ERROR',
        (t) => t,
      );
      expect(access, isNull);
      expect(refresh, isNull);
    },
  );

  test(
    'T16-C6: tras el logout el Bloc queda en SessionUnauthenticated de inmediato',
    () async {
      final bloc = buildBloc();
      bloc.add(const LoggoutUserEvent());

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
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<dynamic> noSuchMethod(Invocation invocation) async => null;
}

class _FakeSharedPreferences implements SharedPreferences {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
