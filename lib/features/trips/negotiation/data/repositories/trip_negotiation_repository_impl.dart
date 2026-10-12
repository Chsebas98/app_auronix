import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/trips/negotiation/data/datasources/trip_negotiation_remote_datasource.dart';
import 'package:auronix_app/features/trips/negotiation/domain/models/published_trip_request.dart';
import 'package:auronix_app/features/trips/negotiation/domain/models/trip_estimate.dart';
import 'package:auronix_app/features/trips/negotiation/domain/repositories/trip_negotiation_repository.dart';
import 'package:dartz/dartz.dart';

class TripNegotiationRepositoryImpl implements TripNegotiationRepository {
  final TripNegotiationRemoteDatasource _remote;

  TripNegotiationRepositoryImpl({
    required TripNegotiationRemoteDatasource remote,
  }) : _remote = remote;

  @override
  Future<Either<Failure, TripEstimate>> estimateTrip({
    required double originLat,
    required double originLng,
    required String originAddress,
    required double destinationLat,
    required double destinationLng,
    required String destinationAddress,
  }) async {
    try {
      final response = await _remote.estimateTrip(
        originLat: originLat,
        originLng: originLng,
        originAddress: originAddress,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        destinationAddress: destinationAddress,
      );

      if (!(response['response'] as bool? ?? false)) {
        return Left(
          ServerFailure(
            message:
                response['message'] ?? 'No se pudo calcular el viaje',
            detail: response['errorDetail'],
            statusCode: response['statusCode'],
          ),
        );
      }

      final result = response['result'] as Map<String, dynamic>?;
      if (result == null) {
        return const Left(
          ServerFailure(
            message: 'Respuesta inválida del servidor',
            statusCode: 500,
          ),
        );
      }

      return Right(TripEstimate.fromJson(result));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al calcular el viaje',
          detail: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, PublishedTripRequest>> publishTripRequest({
    required double originLat,
    required double originLng,
    required String originAddress,
    required double destinationLat,
    required double destinationLng,
    required String destinationAddress,
    required double precioPublicado,
    String? solicitudOriginalId,
  }) async {
    try {
      final response = await _remote.publishTripRequest(
        originLat: originLat,
        originLng: originLng,
        originAddress: originAddress,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        destinationAddress: destinationAddress,
        precioPublicado: precioPublicado,
        solicitudOriginalId: solicitudOriginalId,
      );

      if (!(response['response'] as bool? ?? false)) {
        final statusCode = response['statusCode'] as int?;
        // 409: el pasajero ya tiene una solicitud activa (docs/flow.md
        // sección 3 punto 6) — mensaje claro en vez del genérico del backend.
        final message = statusCode == 409
            ? 'Ya tienes una solicitud de viaje activa. Complétala o '
                  'espera a que expire antes de publicar otra.'
            : (response['message'] ?? 'No se pudo publicar la solicitud');

        return Left(
          ServerFailure(
            message: message,
            detail: response['errorDetail'],
            statusCode: statusCode,
          ),
        );
      }

      final result = response['result'] as Map<String, dynamic>?;
      if (result == null) {
        return const Left(
          ServerFailure(
            message: 'Respuesta inválida del servidor',
            statusCode: 500,
          ),
        );
      }

      return Right(PublishedTripRequest.fromJson(result));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Error inesperado al publicar la solicitud',
          detail: e.toString(),
        ),
      );
    }
  }
}
