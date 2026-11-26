// Prueba PlacesRepositoryImpl (T17) contra un servidor HTTP real local
// (dart:io), mismo patron que auth_repository_backend_test.dart (T11): no
// mockea Dio, levanta /place/autocomplete/json y /place/details/json tal
// como PlacesService los consulta, con PlacesService.baseUrl redirigido al
// servidor de prueba.

import 'dart:convert';
import 'dart:io';

import 'package:auronix_app/core/errors/failure.dart';
import 'package:auronix_app/features/home/data/datasources/places_remote_data_source.dart';
import 'package:auronix_app/features/home/data/repositories/places_repository_impl.dart';
import 'package:auronix_app/features/trips/data/datasources/remote/places_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlacesServer {
  HttpServer? _server;
  int autocompleteStatusCode = 200;
  Map<String, dynamic> autocompleteBody = {'predictions': []};
  bool autocompleteCalled = false;

  int get port => _server!.port;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((request) async {
      if (request.uri.path == '/place/autocomplete/json') {
        autocompleteCalled = true;
        request.response.statusCode = autocompleteStatusCode;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(autocompleteBody));
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

  late _FakePlacesServer server;
  late PlacesRepositoryImpl repository;

  setUp(() async {
    server = _FakePlacesServer();
    await server.start();

    final service = PlacesService(
      apiKey: 'test-key',
      baseUrl: 'http://127.0.0.1:${server.port}',
    );
    repository = PlacesRepositoryImpl(PlacesRemoteDataSource(service));
  });

  tearDown(() async {
    await server.close();
  });

  test(
    'T17-C7: una busqueda exitosa retorna la lista de predicciones mapeada',
    () async {
      server.autocompleteBody = {
        'predictions': [
          {
            'place_id': 'p1',
            'description': 'Parque La Carolina, Quito',
            'structured_formatting': {
              'main_text': 'Parque La Carolina',
              'secondary_text': 'Quito',
            },
          },
        ],
      };

      final result = await repository.searchPredictions('Carolina');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('esperaba Right'), (predictions) {
        expect(predictions, hasLength(1));
        expect(predictions.first.id, 'p1');
        expect(predictions.first.mainText, 'Parque La Carolina');
        expect(predictions.first.secondaryText, 'Quito');
      });
    },
  );

  test('T17-C7: un 500 del servidor se mapea a ServerFailure', () async {
    server.autocompleteStatusCode = 500;
    server.autocompleteBody = {'error_message': 'fallo interno'};

    final result = await repository.searchPredictions('cualquier cosa');

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('esperaba Left'),
    );
  });

  test(
    'T17-C7: un 400 del servidor tambien se mapea a un Failure tipado',
    () async {
      server.autocompleteStatusCode = 400;
      server.autocompleteBody = {'error_message': 'input invalido'};

      final result = await repository.searchPredictions('x');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('esperaba Left'),
      );
    },
  );

  test(
    'T17-C8: una consulta vacia retorna lista vacia sin llamar al servidor',
    () async {
      final result = await repository.searchPredictions('');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('esperaba Right'), (predictions) {
        expect(predictions, isEmpty);
      });
      expect(server.autocompleteCalled, isFalse);
    },
  );

  test(
    'T17-C8: una consulta de solo espacios retorna lista vacia sin llamar al servidor',
    () async {
      final result = await repository.searchPredictions('   ');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('esperaba Right'), (predictions) {
        expect(predictions, isEmpty);
      });
      expect(server.autocompleteCalled, isFalse);
    },
  );
}
