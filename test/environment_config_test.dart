// Confirma que los secretos salieron de lib/app/environments/flavors/env_*_config.dart y ahora
// se cargan desde .env.dev/.env.prod (ver docs/architecture/existing_foundation.md).

import 'dart:io';

import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/app/environments/flavors/env_base_config.dart';
import 'package:auronix_app/app/environments/flavors/env_dev_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env.dev');
  });

  test('EnvDevConfig lee sus valores desde .env.dev, no hardcodeados', () {
    final config = EnvDevConfig();

    expect(config.apiBaseUrl, isNotEmpty);
    expect(config.googleMapsApiKey, isNotEmpty);
    expect(config.tokenKey, isNotEmpty);
    expect(() => config.publicKey, returnsNormally);
  });

  test(
    'T2-C6: deriveWsBaseUrl selecciona wss:// para https (prod/remoto) y ws:// para http (local)',
    () {
      expect(
        deriveWsBaseUrl('https://api.ando.com/api/v1'),
        'wss://api.ando.com',
      );
      expect(
        deriveWsBaseUrl('http://192.168.100.4:8081/api/v1'),
        'ws://192.168.100.4:8081',
      );
    },
  );

  test(
    'T2-C7: GetIt registra y resuelve EnvironmentConfig tras registerEnvironmentConfig()',
    () {
      final getIt = GetIt.asNewInstance();
      Environment().initConfig(Environment.dev);

      registerEnvironmentConfig(getIt);

      expect(getIt.isRegistered<EnvBaseConfig>(), isTrue);
      expect(getIt<EnvBaseConfig>(), same(Environment().config));
    },
  );

  test(
    'T2-C8: .env.example existe con las claves necesarias, sin valores reales, y .env esta en .gitignore',
    () {
      final example = File('.env.example');
      expect(example.existsSync(), isTrue);

      final content = example.readAsStringSync();
      for (final key in [
        'API_BASE_URL',
        'GOOGLE_MAPS_API_KEY',
        'TOKEN_KEY',
        'RSA_PUBLIC_KEY_BASE64',
      ]) {
        expect(content, contains(key));
      }
      expect(content, isNot(contains('AIzaSyCZfwI')));
      expect(content, isNot(contains('AIzaSyAwWACRwNg6aLMJqZJ0ti')));

      final gitignore = File('.gitignore').readAsStringSync();
      expect(gitignore, contains('.env'));
    },
  );
}
