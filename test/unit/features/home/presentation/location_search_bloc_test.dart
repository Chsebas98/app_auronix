// Prueba LocationSearchBloc (T19) con fakes de PlacesRepository y
// DirectionsRepository (no mocks de framework: el repo no usa mockito), que
// cuentan llamadas para probar el debounce y devuelven resultados
// controlables por test.

import 'package:auronix_app/core/errors/failure.dart';
import 'package:auronix_app/features/home/domain/entities/fare_estimate.dart';
import 'package:auronix_app/features/home/domain/entities/place_details.dart';
import 'package:auronix_app/features/home/domain/entities/place_prediction.dart';
import 'package:auronix_app/features/home/domain/entities/route_info.dart';
import 'package:auronix_app/features/home/domain/repositories/directions_repository.dart';
import 'package:auronix_app/features/home/domain/repositories/places_repository.dart';
import 'package:auronix_app/features/home/presentation/bloc/location_search_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class _FakePlacesRepository implements PlacesRepository {
  int searchCallCount = 0;
  Either<Failure, List<PlacePrediction>> searchResult = const Right([]);
  Either<Failure, PlaceDetails> detailsResult = const Right(
    PlaceDetails(latitude: 0, longitude: 0, formattedAddress: ''),
  );

  @override
  Future<Either<Failure, List<PlacePrediction>>> searchPredictions(
    String query,
  ) async {
    searchCallCount++;
    return searchResult;
  }

  @override
  Future<Either<Failure, PlaceDetails>> getPlaceDetails(String placeId) async {
    return detailsResult;
  }
}

class _FakeDirectionsRepository implements DirectionsRepository {
  int getRouteCallCount = 0;
  Either<Failure, RouteInfo> routeResult = const Right(
    RouteInfo(
      points: [LatLng(0, 0)],
      distanceMeters: 1000,
      durationSeconds: 120,
      polylineEncoded: 'abc',
    ),
  );
  Either<Failure, FareEstimate> fareResult = const Right(
    FareEstimate(
      estimatedPrice: 2.0,
      currency: 'USD',
      baseFare: 1.0,
      distanceFare: 0.5,
      timeFare: 0.5,
    ),
  );

  @override
  Future<Either<Failure, RouteInfo>> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    getRouteCallCount++;
    return routeResult;
  }

  @override
  Future<Either<Failure, FareEstimate>> estimateFare({
    required double distanceMeters,
    required int durationSeconds,
  }) async {
    return fareResult;
  }
}

PlacePrediction _prediction(String id) => PlacePrediction(
  id: id,
  mainText: 'Lugar $id',
  secondaryText: 'Ciudad',
  latitude: 0,
  longitude: 0,
);

void main() {
  late _FakePlacesRepository places;
  late _FakeDirectionsRepository directions;

  setUp(() {
    places = _FakePlacesRepository();
    directions = _FakeDirectionsRepository();
  });

  LocationSearchBloc buildBloc({Duration? debounceDuration}) =>
      LocationSearchBloc(
        placesRepository: places,
        directionsRepository: directions,
        debounceDuration: debounceDuration ?? const Duration(milliseconds: 30),
      );

  test(
    'T19-C8: emisiones repetidas de SearchQueryChanged en menos del tiempo de debounce ejecutan una sola llamada',
    () async {
      places.searchResult = Right([_prediction('p1')]);
      final bloc = buildBloc();

      bloc.add(const SearchQueryChanged('a', true));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      bloc.add(const SearchQueryChanged('ab', true));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      bloc.add(const SearchQueryChanged('abc', true));

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<LocationSearchState>().having(
            (s) => s.predictions,
            'predictions',
            isNotEmpty,
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(places.searchCallCount, 1);
      await bloc.close();
    },
  );

  test(
    'T19-C10: una busqueda sin coincidencias deja predictions vacia y hasNoResults en verdadero',
    () async {
      places.searchResult = const Right([]);
      final bloc = buildBloc();

      bloc.add(const SearchQueryChanged('nada por aqui', true));

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<LocationSearchState>()
              .having((s) => s.hasNoResults, 'hasNoResults', isTrue)
              .having((s) => s.predictions, 'predictions', isEmpty),
        ),
      );
      await bloc.close();
    },
  );

  test(
    'T19-C11: con origen y destino seleccionados, transiciona a isCalculatingRoute y luego a routeReady con routeInfo y fareEstimate',
    () async {
      places.detailsResult = const Right(
        PlaceDetails(
          latitude: 10,
          longitude: 20,
          formattedAddress: 'Direccion resuelta',
        ),
      );
      final bloc = buildBloc();
      // Se registran todos los estados emitidos desde ANTES de disparar los
      // eventos: bloc.stream es un broadcast stream, asi que un segundo
      // listener adjuntado despues de que el Bloc ya resolvio todo no vería
      // nada (el stream no reproduce historial) — por eso una sola
      // suscripcion para toda la prueba, en vez de dos expectLater en serie.
      final states = <LocationSearchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc
        ..add(const SetCurrentLocationAsOrigin(LatLng(0, 0), 'Mi ubicacion'))
        ..add(SelectPlace(_prediction('dest1'), false));

      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (!bloc.state.isRouteReady && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      await sub.cancel();
      await bloc.close();

      expect(states.any((s) => s.isCalculatingRoute), isTrue);
      expect(bloc.state.isRouteReady, isTrue);
      expect(bloc.state.routeInfo, isNotNull);
      expect(bloc.state.fareEstimate, isNotNull);
    },
  );

  test(
    'T19-C9: SwapLocations con origen y destino cargados intercambia las posiciones y recalcula la ruta',
    () async {
      places.detailsResult = const Right(
        PlaceDetails(latitude: 10, longitude: 20, formattedAddress: 'Destino'),
      );
      final bloc = buildBloc();

      bloc
        ..add(const SetCurrentLocationAsOrigin(LatLng(1, 1), 'Origen inicial'))
        ..add(SelectPlace(_prediction('dest1'), false));

      var deadline = DateTime.now().add(const Duration(seconds: 5));
      while (!bloc.state.isRouteReady && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      expect(bloc.state.isRouteReady, isTrue);

      final callsBeforeSwap = directions.getRouteCallCount;
      final originBeforeSwap = bloc.state.origin;
      final destinationBeforeSwap = bloc.state.destination;

      bloc.add(const SwapLocations());

      deadline = DateTime.now().add(const Duration(seconds: 5));
      while (directions.getRouteCallCount <= callsBeforeSwap &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }

      expect(bloc.state.origin, destinationBeforeSwap);
      expect(bloc.state.destination, originBeforeSwap);
      expect(directions.getRouteCallCount, greaterThan(callsBeforeSwap));
      await bloc.close();
    },
  );
}
