import 'package:pointycastle/asymmetric/api.dart';

abstract class EnvBaseConfig {
  String get apiBaseUrl;
  String get tokenKey;
  RSAPublicKey get publicKey;
}
