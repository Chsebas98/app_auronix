import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/negotiation/data/datasources/geo_remote_datasource.dart';
import 'package:auronix_app/features/trips/negotiation/domain/models/address_suggestion.dart';
import 'package:auronix_app/features/trips/negotiation/domain/repositories/geo_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class GeoRepositoryImpl implements GeoRepository {
  final GeoRemoteDatasource _remote;

  GeoRepositoryImpl({required GeoRemoteDatasource remote}) : _remote = remote;

  @override
  Future<Either<Failure, List<AddressSuggestion>>> autocomplete({
    required String query,
    double? lat,
    double? lng,
  }) async {
    try {
      final result = await _remote.autocomplete(
        query: query,
        lat: lat,
        lng: lng,
      );
      return Right(
        result
            .whereType<Map<String, dynamic>>()
            .map(AddressSuggestion.fromJson)
            .toList(),
      );
    } on DioException catch (e) {
      return Left(
        NetworkFailure(
          message: 'No se pudo buscar direcciones',
          detail: e.message,
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al buscar direcciones',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    try {
      final result = await _remote.reverse(lat: lat, lng: lng);
      return Right(result['label'] as String? ?? '');
    } on DioException catch (e) {
      return Left(
        NetworkFailure(
          message: 'No se pudo obtener la dirección',
          detail: e.message,
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al obtener la dirección',
          detail: e.toString(),
        ),
      );
    }
  }
}
