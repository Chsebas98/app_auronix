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

/// Deriva la URL base de WebSocket a partir de apiBaseUrl: http://host:port/api -> ws://host:port,
/// https://host:port/api -> wss://host:port. wss:// es obligatorio cuando apiBaseUrl es https://
/// (desarrollo remoto/producción); ws:// sin cifrar solo aplica a http:// local.
///
/// Usa Uri.parse en vez de recortar el string a mano: un recorte textual de "/api" se come de más
/// cuando el host empieza con "api." (ej. https://api.ando.com/api/v1 quedaba en "wss:/" roto,
/// porque "/api" también matcheaba justo después del "//" del esquema).
String deriveWsBaseUrl(String apiBaseUrl) {
  final uri = Uri.parse(apiBaseUrl);
  final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
  final authority = uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
  return '$wsScheme://$authority';
}
