import 'package:pointycastle/asymmetric/api.dart';

abstract class EnvBaseConfig {
  String get apiBaseUrl;
  RSAPublicKey get publicKey;
}
