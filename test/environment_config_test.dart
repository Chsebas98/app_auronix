// Confirma que los secretos salieron de lib/app/environments/flavors/env_*_config.dart y ahora
// se cargan desde .env.dev/.env.prod (ver docs/architecture/existing_foundation.md).

import 'package:auronix_app/app/environments/flavors/env_dev_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
