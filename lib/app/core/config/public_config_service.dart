import 'package:auronix_app/app/core/config/public_config.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

/// `GET /config/public` con cache de 1h (docs/requerimientos_backend.md
/// sección 4.4) — el cliente lo consulta al arrancar y reutiliza el valor
/// cacheado en cada pantalla que lo necesite, sin repetir el round-trip.
///
/// docs/testing.md caso #19: si la consulta falla, nunca se inventa un
/// valor — se devuelve el último cacheado (aunque haya expirado) o, si
/// nunca hubo uno, un [Failure] explícito para que el llamador bloquee la
/// acción dependiente con un mensaje claro.
class PublicConfigService {
  static const _cacheTtl = Duration(hours: 1);
  static String get _baseUrl => Environment().config!.apiBaseUrl;

  final Dio _dio;

  PublicConfig? _cached;
  DateTime? _cachedAt;

  PublicConfigService({required Dio dio}) : _dio = dio;

  PublicConfig? get cached => _cached;

  Future<Either<Failure, PublicConfig>> getConfig({
    bool forceRefresh = false,
  }) async {
    final isFresh =
        _cached != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheTtl;

    if (!forceRefresh && isFresh) {
      return Right(_cached!);
    }

    try {
      final response = await _dio.get('$_baseUrl/config/public');
      final config = PublicConfig.fromJson(
        response.data as Map<String, dynamic>,
      );
      _cached = config;
      _cachedAt = DateTime.now();
      return Right(config);
    } catch (e) {
      if (_cached != null) return Right(_cached!);
      return Left(
        NetworkFailure(
          message: 'No se pudo obtener la configuración del servidor',
          detail: e.toString(),
        ),
      );
    }
  }
}
