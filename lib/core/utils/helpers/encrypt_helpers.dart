import 'dart:convert';
import 'dart:typed_data';

import 'package:auronix_app/app/environments/environment.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/asymmetric/api.dart' as pc;

class EncryptHelpers {
  final dynamic _dataJson;
  final pc.RSAPublicKey _publicKey = Environment().config!.publicKey;
  final int _aesKeySize = 32;
  final int _ivSize = 16;

  EncryptHelpers({required dynamic dataJson}) : _dataJson = dataJson;

  String get payload {
    final cipherBytes = _encryptHybridRaw(_dataJson, _publicKey);
    return base64.encode(cipherBytes);
  }

  Uint8List _encryptHybridRaw(String plainJson, pc.RSAPublicKey publicKey) {
    final plainBytes = utf8.encode(plainJson);
    final aesKey = encrypt.Key.fromSecureRandom(_aesKeySize);
    final iv = encrypt.IV.fromSecureRandom(_ivSize);

    final aesEncrypter = encrypt.Encrypter(
      encrypt.AES(aesKey, mode: encrypt.AESMode.cbc),
    );
    final encryptedData = aesEncrypter.encryptBytes(plainBytes, iv: iv);

    final rsaEncrypter = encrypt.Encrypter(encrypt.RSA(publicKey: publicKey));
    final encryptedKey = rsaEncrypter.encryptBytes(aesKey.bytes);

    return Uint8List.fromList([
      ...encryptedKey.bytes,
      ...iv.bytes,
      ...encryptedData.bytes,
    ]);
  }
}
