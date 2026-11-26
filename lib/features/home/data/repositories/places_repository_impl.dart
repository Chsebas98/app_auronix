import 'package:auronix_app/app/network/error_mapper.dart';
import 'package:auronix_app/core/errors/failure.dart';
import 'package:auronix_app/features/home/data/datasources/places_remote_data_source.dart';
import 'package:auronix_app/features/home/domain/entities/place_details.dart';
import 'package:auronix_app/features/home/domain/entities/place_prediction.dart';
import 'package:auronix_app/features/home/domain/repositories/places_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  PlacesRepositoryImpl(this._remote);

  final PlacesRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<PlacePrediction>>> searchPredictions(
    String query,
  ) async {
    // T17-C3: una consulta vacia o solo espacios no dispara peticion HTTP.
    if (query.trim().isEmpty) return const Right([]);

    try {
      final dtos = await _remote.searchPredictions(query.trim());
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'No se pudo buscar lugares.',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, PlaceDetails>> getPlaceDetails(String placeId) async {
    try {
      final dto = await _remote.getPlaceDetails(placeId);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'No se pudo obtener el detalle del lugar.',
          detail: e.toString(),
        ),
      );
    }
  }
}
