import 'package:auronix_app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persiste tokens JWT y datos de sesión cifrados en el llavero nativo
/// (Keychain en iOS / Keystore en Android), en vez de texto plano en SQLite
/// (ver docs/architecture/existing_foundation.md, hallazgo 1 de la Tarea 0).
abstract class SecureStorageService {
  Future<Either<Failure, void>> write(String key, String value);
  Future<Either<Failure, String?>> read(String key);

  Future<Either<Failure, void>> saveAccessToken(String token);
  Future<Either<Failure, String?>> getAccessToken();
  Future<Either<Failure, void>> saveRefreshToken(String token);
  Future<Either<Failure, String?>> getRefreshToken();

  /// Elimina por completo tokens y datos de sesión, sin dejar remanentes.
  Future<Either<Failure, void>> clearSession();
}

class SecureStorageServiceImpl implements SecureStorageService {
  SecureStorageServiceImpl({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const keyAccessToken = 'secure_access_token';
  static const keyRefreshToken = 'secure_refresh_token';

  @override
  Future<Either<Failure, void>> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      return const Right(null);
    } catch (e) {
      return Left(
        StorageFailure(
          message: 'No se pudo escribir en el almacenamiento seguro',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String?>> read(String key) async {
    try {
      final value = await _storage.read(key: key);
      return Right(value);
    } catch (e) {
      return Left(
        StorageFailure(
          message: 'No se pudo leer del almacenamiento seguro',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveAccessToken(String token) =>
      write(keyAccessToken, token);

  @override
  Future<Either<Failure, String?>> getAccessToken() => read(keyAccessToken);

  @override
  Future<Either<Failure, void>> saveRefreshToken(String token) =>
      write(keyRefreshToken, token);

  @override
  Future<Either<Failure, String?>> getRefreshToken() => read(keyRefreshToken);

  @override
  Future<Either<Failure, void>> clearSession() async {
    try {
      await _storage.delete(key: keyAccessToken);
      await _storage.delete(key: keyRefreshToken);
      return const Right(null);
    } catch (e) {
      return Left(
        StorageFailure(
          message: 'No se pudo limpiar la sesión del almacenamiento seguro',
          detail: e.toString(),
        ),
      );
    }
  }
}
