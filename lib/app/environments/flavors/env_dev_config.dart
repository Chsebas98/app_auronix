import 'package:auronix_app/app/environments/flavors/env_base_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pointycastle/asymmetric/api.dart';

class EnvDevConfig extends EnvBaseConfig {
  @override
  String get apiBaseUrl => dotenv.env['API_BASE_URL']!;

  @override
  String get tokenKey => dotenv.env['TOKEN_KEY']!;

  @override
  String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY']!;

  @override
  RSAPublicKey get publicKey => parsePublicKeyFromPem(
    decodeBase64Pem(dotenv.env['RSA_PUBLIC_KEY_BASE64']!),
  );
}
