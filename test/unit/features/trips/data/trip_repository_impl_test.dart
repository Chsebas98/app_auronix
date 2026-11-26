// Prueba TripRepositoryImpl.requestTrip (T23) contra un servidor HTTP real
// local (dart:io), mismo patron que places_repository_impl_test.dart (T17):
// no mockea Dio, levanta un endpoint que responde como lo haria el backend
// real y redirige Environment().config.apiBaseUrl a ese servidor.

import 'dart:convert';
import 'dart:io';

import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/app/environments/flavors/env_base_config.dart';
import 'package:auronix_app/features/trips/data/datasources/remote/client_trip_remote_datasource.dart';
import 'package:auronix_app/features/trips/data/datasources/remote/driver_trip_remote_datasource.dart';
import 'package:auronix_app/features/trips/data/repository/trip_repository_impl.dart';
import 'package:auronix_app/features/trips/domain/exceptions/active_trip_exception.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_status.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/accept_trip_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/complete_trip_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/get_available_trips_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/start_trip_usecase.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/asymmetric/api.dart';

class _FakeEnvConfig implements EnvBaseConfig {
  _FakeEnvConfig(this.apiBaseUrl);

  @override
  final String apiBaseUrl;

  @override
  String get googleMapsApiKey => throw UnimplementedError();

  @override
  String get tokenKey => throw UnimplementedError();

  @override
  RSAPublicKey get publicKey => throw UnimplementedError();
}

class _FakeTripServer {
  HttpServer? _server;
  int statusCode = 200;
  Map<String, dynamic> body = {
    'result': {'id': 1, 'estado': 'SOLICITADO'},
  };

  int get port => _server!.port;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((request) async {
      request.response.statusCode = statusCode;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(body));
      await request.response.close();
    });
  }

  Future<void> close() async => _server?.close(force: true);
}

void main() {
  late _FakeTripServer server;
  late TripRepositoryImpl repository;

  setUp(() async {
    server = _FakeTripServer();
    await server.start();
    Environment().config = _FakeEnvConfig(
      'http://127.0.0.1:${server.port}/api/v1',
    );
    final dio = Dio();
    repository = TripRepositoryImpl(
      clientRemote: ClientTripRemoteDatasource(dio: dio),
      driverRemote: DriverTripRemoteDatasource(dio: dio),
    );
  });

  tearDown(() async {
    await server.close();
  });

  group('TripRepositoryImpl.requestTrip', () {
    test(
      'T23-C4: lanza ActiveTripException cuando el backend devuelve 409',
      () async {
        server.statusCode = 409;
        server.body = {'detail': 'Ya existe un viaje activo'};

        await expectLater(
          repository.requestTrip(
            userId: 1,
            origenLatitud: -0.1,
            origenLongitud: -78.5,
            origenDireccion: 'Origen',
            destinoLatitud: -0.2,
            destinoLongitud: -78.4,
            destinoDireccion: 'Destino',
            distanciaEstimadaKm: 3.2,
          ),
          throwsA(isA<ActiveTripException>()),
        );
      },
    );

    test(
      'un 500 no se confunde con un conflicto de viaje activo: devuelve Left(ServerFailure)',
      () async {
        server.statusCode = 500;
        server.body = {'detail': 'Internal error'};

        final result = await repository.requestTrip(
          userId: 1,
          origenLatitud: -0.1,
          origenLongitud: -78.5,
          origenDireccion: 'Origen',
          destinoLatitud: -0.2,
          destinoLongitud: -78.4,
          destinoDireccion: 'Destino',
          distanciaEstimadaKm: 3.2,
        );

        expect(result.isLeft(), isTrue);
      },
    );
  });

  test(
    'T30-C3: los casos de uso del conductor preservan estados del backend',
    () async {
      server.body = {
        'result': [
          for (final status in [
            'SOLICITADO',
            'OFERTADO',
            'ACEPTADO',
            'EN_CURSO',
            'COMPLETADO',
            'CANCELADO',
          ])
            {'id': 1, 'cooperativaId': 2, 'estado': status},
        ],
      };
      final available = await GetAvailableTripsUseCase(repository)(7);
      expect(
        available.fold(
          (_) => null,
          (trips) => trips.map((t) => t.estado).toList(),
        ),
        TripStatus.values,
      );

      server.body = {
        'result': {'id': 1, 'cooperativaId': 2, 'estado': 'ACEPTADO'},
      };
      final accepted = await AcceptTripUseCase(repository)(
        userId: 7,
        tripId: 1,
      );
      expect(
        accepted.fold((_) => null, (trip) => trip.estado),
        TripStatus.aceptado,
      );

      server.body = {
        'result': {'id': 1, 'cooperativaId': 2, 'estado': 'EN_CURSO'},
      };
      final started = await StartTripUseCase(repository)(userId: 7, tripId: 1);
      expect(
        started.fold((_) => null, (trip) => trip.estado),
        TripStatus.enCurso,
      );

      server.body = {
        'result': {
          'id': 1,
          'estado': 'COMPLETADO',
          'precioTotal': 5,
          'comisionMonto': 1,
          'montoConductor': 4,
        },
      };
      final completed = await CompleteTripUseCase(repository)(
        userId: 7,
        tripId: 1,
        distanciaFinalKm: 3,
        duracionMinutos: 10,
      );
      expect(completed.fold((_) => null, (trip) => trip.estado), 'COMPLETADO');
    },
  );

  test('T30-C4: ofertas requieren cooperativaId entero positivo', () async {
    final getAvailableTrips = GetAvailableTripsUseCase(repository);
    final invalidOffers = <Map<String, dynamic>>[
      {'id': 2},
      {'id': 2, 'cooperativaId': null},
      {'id': 2, 'cooperativaId': ''},
      {'id': 2, 'cooperativaId': '2'},
      {'id': 2, 'cooperativaId': 2.5},
      {'id': 2, 'cooperativaId': 0},
      {'id': 2, 'cooperativaId': -1},
    ];

    for (final invalidOffer in invalidOffers) {
      server.body = {
        'result': [
          {'id': 1, 'cooperativaId': 2},
          invalidOffer,
        ],
      };
      expect((await getAvailableTrips(7)).isLeft(), isTrue);
    }

    server.body = {
      'result': [
        {'id': 1, 'cooperativaId': 2},
      ],
    };
    final valid = await getAvailableTrips(7);
    expect(valid.fold((_) => null, (trips) => trips.single.cooperativaId), 2);

    server.body = {'result': <dynamic>[]};
    final empty = await getAvailableTrips(7);
    expect(empty.fold((_) => null, (trips) => trips), isEmpty);
  });
}
