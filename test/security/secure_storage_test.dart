// Prueba SecureStorageService contra un mock real del MethodChannel nativo de
// flutter_secure_storage (plugins.it_nomads.com/flutter_secure_storage), no un
// fake propio — así se confirma que de verdad llama al llavero nativo
// (Keychain/Keystore) y no a SharedPreferences/SQLite sin cifrar.

import 'package:auronix_app/app/core/network/secure_storage_service.dart';
import 'package:auronix_app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  late Map<String, String> fakeKeychain;
  late List<String> invokedMethods;
  var throwOnNextCall = false;

  void installMockHandler() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          invokedMethods.add(call.method);
          if (throwOnNextCall) {
            throwOnNextCall = false;
            throw PlatformException(
              code: 'simulated_native_error',
              message: 'Fallo simulado del llavero nativo',
            );
          }
          switch (call.method) {
            case 'write':
              fakeKeychain[call.arguments['key'] as String] =
                  call.arguments['value'] as String;
              return null;
            case 'read':
              return fakeKeychain[call.arguments['key'] as String];
            case 'delete':
              fakeKeychain.remove(call.arguments['key'] as String);
              return null;
            case 'deleteAll':
              fakeKeychain.clear();
              return null;
            case 'containsKey':
              return fakeKeychain.containsKey(call.arguments['key'] as String);
            default:
              return null;
          }
        });
  }

  setUp(() {
    fakeKeychain = {};
    invokedMethods = [];
    throwOnNextCall = false;
    installMockHandler();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'T5-C1: guarda y recupera un valor de prueba cifrado en el llavero del sistema',
    () async {
      final service = SecureStorageServiceImpl();

      final writeResult = await service.write('clave_prueba', 'valor_prueba');
      expect(writeResult.isRight(), isTrue);

      final readResult = await service.read('clave_prueba');
      expect(readResult, const Right<Failure, String?>('valor_prueba'));
      expect(invokedMethods, containsAll(['write', 'read']));
    },
  );

  test(
    'T5-C2: el metodo de borrado elimina todas las claves de sesion al cerrar sesion',
    () async {
      final service = SecureStorageServiceImpl();
      await service.saveAccessToken('access-123');
      await service.saveRefreshToken('refresh-456');
      expect(fakeKeychain.length, 2);

      final result = await service.clearSession();

      expect(result.isRight(), isTrue);
      expect(fakeKeychain, isEmpty);
    },
  );

  test(
    'T5-C3: SecureStorageService persiste y recupera tokens JWT con cifrado nativo',
    () async {
      final service = SecureStorageServiceImpl();

      await service.saveAccessToken('jwt-access-token');
      await service.saveRefreshToken('jwt-refresh-token');

      final access = await service.getAccessToken();
      final refresh = await service.getRefreshToken();

      expect(access, const Right<Failure, String?>('jwt-access-token'));
      expect(refresh, const Right<Failure, String?>('jwt-refresh-token'));
    },
  );

  test(
    'T5-C4: el borrado de sesion purga por completo tokens y llaves sin remanentes',
    () async {
      final service = SecureStorageServiceImpl();
      await service.saveAccessToken('access-123');
      await service.saveRefreshToken('refresh-456');

      await service.clearSession();

      final access = await service.getAccessToken();
      final refresh = await service.getRefreshToken();
      expect(access, const Right<Failure, String?>(null));
      expect(refresh, const Right<Failure, String?>(null));
    },
  );

  test(
    'T5-C5: las excepciones de lectura/escritura se capturan y mapean a StorageFailure',
    () async {
      final service = SecureStorageServiceImpl();
      throwOnNextCall = true;

      final result = await service.write('clave', 'valor');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<StorageFailure>()),
        (_) => fail('se esperaba un StorageFailure'),
      );
    },
  );

  test(
    'T5-C6: los tokens se persisten usando Flutter Secure Storage (Keychain/Keystore), no SQLite/SharedPreferences',
    () async {
      final service = SecureStorageServiceImpl();

      await service.saveAccessToken('jwt-access-token');

      // El llamado real paso por el MethodChannel nativo de flutter_secure_storage.
      expect(invokedMethods, contains('write'));
      expect(
        fakeKeychain[SecureStorageServiceImpl.keyAccessToken],
        'jwt-access-token',
      );
    },
  );

  test(
    'T5-C7: clearSession() remueve completamente los tokens en el logout sin dejar residuos',
    () async {
      final service = SecureStorageServiceImpl();
      await service.saveAccessToken('access-123');
      await service.saveRefreshToken('refresh-456');

      final result = await service.clearSession();

      expect(result.isRight(), isTrue);
      expect(fakeKeychain, isEmpty);
      expect(invokedMethods, containsAll(['delete']));
    },
  );
}
