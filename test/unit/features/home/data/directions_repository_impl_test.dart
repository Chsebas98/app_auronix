// Prueba DirectionsRepositoryImpl (T18) contra un servidor HTTP real local
// (dart:io), mismo patron que places_repository_impl_test.dart (T17):
// PlacesService.baseUrl redirigido al servidor de prueba.

import 'dart:convert';
import 'dart:io';

import 'package:auronix_app/core/errors/failure.dart';
import 'package:auronix_app/features/home/data/datasources/directions_remote_data_source.dart';
import 'package:auronix_app/features/home/data/repositories/directions_repository_impl.dart';
import 'package:auronix_app/features/trips/data/datasources/remote/places_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class _FakeDirectionsServer {
  HttpServer? _server;
  Map<String, dynamic> body = {'status': 'OK', 'routes': []};

  int get port => _server!.port;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((request) async {
      if (request.uri.path == '/directions/json') {
        request.response.statusCode = 200;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(body));
      } else {
        request.response.statusCode = 404;
      }
      await request.response.close();
    });
  }

  Future<void> close() async => _server?.close(force: true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  late _FakeDirectionsServer server;
  late DirectionsRepositoryImpl repository;

  setUp(() async {
    server = _FakeDirectionsServer();
    await server.start();

    final service = PlacesService(
      apiKey: 'test-key',
      baseUrl: 'http://127.0.0.1:${server.port}',
    );
    repository = DirectionsRepositoryImpl(DirectionsRemoteDataSource(service));
  });

  tearDown(() async {
    await server.close();
  });

  test(
    'T18-C6: decodifica la polilinea codificada en una lista de LatLng sin perder precision',
    () async {
      // '_p~iF~ps|U_ulLnnqC_mqNvxq`@' es el ejemplo canonico de la
      // documentacion de Google para el algoritmo de polyline encoding;
      // decodifica a exactamente estos 3 puntos.
      server.body = {
        'status': 'OK',
        'routes': [
          {
            'overview_polyline': {'points': '_p~iF~ps|U_ulLnnqC_mqNvxq`@'},
            'legs': [
              {
                'distance': {'value': 15320},
                'duration': {'value': 1500},
              },
            ],
          },
        ],
      };

      final result = await repository.getRoute(
        origin: const LatLng(38.5, -120.2),
        destination: const LatLng(43.252, -126.453),
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('esperaba Right'), (route) {
        expect(route.points, hasLength(3));
        expect(route.points[0].latitude, closeTo(38.5, 1e-5));
        expect(route.points[0].longitude, closeTo(-120.2, 1e-5));
        expect(route.points[1].latitude, closeTo(40.7, 1e-5));
        expect(route.points[1].longitude, closeTo(-120.95, 1e-5));
        expect(route.points[2].latitude, closeTo(43.252, 1e-5));
        expect(route.points[2].longitude, closeTo(-126.453, 1e-5));
        expect(route.distanceMeters, 15320);
        expect(route.durationSeconds, 1500);
      });
    },
  );

  test('T18-C8: ZERO_RESULTS se mapea a RouteNotFoundFailure', () async {
    server.body = {'status': 'ZERO_RESULTS', 'routes': []};

    final result = await repository.getRoute(
      origin: const LatLng(0, 0),
      destination: const LatLng(0, 0),
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<RouteNotFoundFailure>()),
      (_) => fail('esperaba Left'),
    );
  });

  test('T18-C8: NOT_FOUND tambien se mapea a RouteNotFoundFailure', () async {
    server.body = {'status': 'NOT_FOUND', 'routes': []};

    final result = await repository.getRoute(
      origin: const LatLng(0, 0),
      destination: const LatLng(0, 0),
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<RouteNotFoundFailure>()),
      (_) => fail('esperaba Left'),
    );
  });

  test(
    'T18-C7: estimateFare calcula el total con tarifa base, distancia y tiempo redondeado a 2 decimales',
    () async {
      final result = await repository.estimateFare(
        distanceMeters: 10000,
        durationSeconds: 1200,
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('esperaba Right'), (estimate) {
        // base 1.00 + 10km*0.35 + 20min*0.05 = 1.00 + 3.50 + 1.00 = 5.50
        expect(estimate.baseFare, 1.00);
        expect(estimate.distanceFare, 3.50);
        expect(estimate.timeFare, 1.00);
        expect(estimate.estimatedPrice, 5.50);
        expect(estimate.currency, 'USD');
      });
    },
  );

  test(
    'T18-C7: redondea a dos decimales cuando el calculo no es exacto',
    () async {
      final result = await repository.estimateFare(
        distanceMeters: 1234,
        durationSeconds: 97,
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('esperaba Right'), (estimate) {
        final decimals = estimate.estimatedPrice
            .toStringAsFixed(10)
            .split('.')[1];
        expect(decimals.replaceFirst(RegExp(r'0+$'), '').length <= 2, isTrue);
      });
    },
  );
}
