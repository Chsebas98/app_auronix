import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

abstract class EnvBaseConfig {
  String get apiBaseUrl;
  String get googleMapsApiKey;
  String get tokenKey;
  RSAPublicKey get publicKey;
}

/// Decodifica una clave PEM guardada en base64 (formato de las variables de entorno
/// RSA_PUBLIC_KEY_BASE64), para no tener que pegar bloques PEM multilinea en el .env.
String decodeBase64Pem(String base64Pem) => utf8.decode(base64.decode(base64Pem));

/// Parsea un string PEM a RSAPublicKey usando la libreria pointycastle.
RSAPublicKey parsePublicKeyFromPem(String pemString) {
  final parser = RSAKeyParser();
  final publicKey = parser.parse(pemString) as RSAPublicKey;
  return publicKey;
}
