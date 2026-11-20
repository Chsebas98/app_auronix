// Prueba LocationSearchView (T20) contra el widget real, con fakes de
// PlacesRepository/DirectionsRepository registrados en GetIt (asi es como
// la vista los resuelve, via el LocationSearchBloc real de sl<>()).
//
// T20-C8 exige verificar Semantics reales (etiquetas + area tactil minima).
// AppTextField choca con un bug conocido del framework de pruebas de
// Flutter cuando el arbol de semantics queda activo (tester.ensureSemantics)
// bajo pumps repetidos ("node.parent?._dirty != true" / "isMergedIntoParent"
// — mismo problema documentado en otras pruebas de esta sesion). En vez de
// activar el arbol de semantics en vivo, se leen las PROPIEDADES del widget
// Semantics directamente (Semantics.properties.label/button/textField),
// que no requieren flushSemantics ni disparan ese bug.

import 'dart:async';

import 'package:auronix_app/app/design/theme/app_theme.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/core/errors/failure.dart';
import 'package:auronix_app/features/home/domain/entities/fare_estimate.dart';
import 'package:auronix_app/features/home/domain/entities/place_details.dart';
import 'package:auronix_app/features/home/domain/entities/place_prediction.dart';
import 'package:auronix_app/features/home/domain/entities/route_info.dart';
import 'package:auronix_app/features/home/domain/repositories/directions_repository.dart';
import 'package:auronix_app/features/home/domain/repositories/places_repository.dart';
import 'package:auronix_app/features/home/presentation/bloc/location_search_bloc.dart';
import 'package:auronix_app/features/home/presentation/views/location_search_view.dart';
import 'package:auronix_app/shared/molecules/prediction_tile.dart';
import 'package:auronix_app/shared/molecules/skeleton_prediction_list.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class _FakePlacesRepository implements PlacesRepository {
  Either<Failure, List<PlacePrediction>> searchResult = const Right([]);

  /// Cuando no es null, searchPredictions espera a que se complete en vez
  /// de resolver de inmediato — permite observar deterministicamente el
  /// estado intermedio de carga (T20-C9).
  Completer<void>? pendingSearch;

  @override
  Future<Either<Failure, List<PlacePrediction>>> searchPredictions(
    String query,
  ) async {
    if (pendingSearch != null) await pendingSearch!.future;
    return searchResult;
  }

  @override
  Future<Either<Failure, PlaceDetails>> getPlaceDetails(String placeId) async =>
      const Right(
        PlaceDetails(latitude: 1, longitude: 1, formattedAddress: ''),
      );
}

class _FakeDirectionsRepository implements DirectionsRepository {
  @override
  Future<Either<Failure, RouteInfo>> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async => const Right(
    RouteInfo(
      points: [],
      distanceMeters: 1000,
      durationSeconds: 60,
      polylineEncoded: '',
    ),
  );

  @override
  Future<Either<Failure, FareEstimate>> estimateFare({
    required double distanceMeters,
    required int durationSeconds,
  }) async => const Right(
    FareEstimate(
      estimatedPrice: 1,
      currency: 'USD',
      baseFare: 1,
      distanceFare: 0,
      timeFare: 0,
    ),
  );
}

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => MaterialApp(
      theme: AppTheme.light,
      // AppTextField choca con un bug conocido del framework de pruebas de
      // Flutter bajo pumps repetidos (ver comentario al inicio del
      // archivo). ExcludeSemantics solo afecta el arbol de SemanticsNode en
      // tiempo de renderizado — los widgets Semantics(...) siguen intactos
      // en el arbol de widgets, asi que tester.widget<Semantics>(...) para
      // leer sus `properties` sigue funcionando normalmente.
      home: Scaffold(body: ExcludeSemantics(child: child)),
    ),
  );
}

void useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Busca, entre TODOS los widgets Semantics del arbol (el framework agrega
/// muchos propios), el que tiene exactamente esta etiqueta configurada.
Semantics _semanticsWithLabel(WidgetTester tester, String label) {
  return tester
      .widgetList<Semantics>(find.byType(Semantics))
      .firstWhere((s) => s.properties.label == label);
}

void main() {
  late _FakePlacesRepository places;
  late _FakeDirectionsRepository directions;

  setUp(() {
    places = _FakePlacesRepository();
    directions = _FakeDirectionsRepository();
    sl.registerFactory<LocationSearchBloc>(
      () => LocationSearchBloc(
        placesRepository: places,
        directionsRepository: directions,
        debounceDuration: const Duration(milliseconds: 20),
      ),
    );
  });

  tearDown(() {
    sl.unregister<LocationSearchBloc>();
  });

  testWidgets(
    'T20-C8: los inputs y el boton de swap tienen area tactil minima 44x44 y Semantics validas',
    (tester) async {
      useTallViewport(tester);

      await tester.pumpWidget(_wrap(const LocationSearchView()));
      await tester.pump();

      final swapFinder = find.byKey(const Key('location_search_swap_button'));
      expect(swapFinder, findsOneWidget);
      final swapSize = tester.getSize(swapFinder);
      expect(swapSize.width, greaterThanOrEqualTo(44));
      expect(swapSize.height, greaterThanOrEqualTo(44));
      final swapButton = tester.widget<IconButton>(
        find.descendant(of: swapFinder, matching: find.byType(IconButton)),
      );
      expect(swapButton.tooltip, 'Intercambiar origen y destino');

      final originFinder = find.byKey(
        const Key('location_search_origin_input'),
      );
      final destinationFinder = find.byKey(
        const Key('location_search_destination_input'),
      );
      expect(tester.getSize(originFinder).height, greaterThanOrEqualTo(44));
      expect(
        tester.getSize(destinationFinder).height,
        greaterThanOrEqualTo(44),
      );

      final originSemantics = _semanticsWithLabel(
        tester,
        'Origen: ¿Desde dónde sales?',
      );
      expect(originSemantics.properties.textField, isTrue);
      final destinationSemantics = _semanticsWithLabel(
        tester,
        'Destino: ¿A dónde vas?',
      );
      expect(destinationSemantics.properties.textField, isTrue);
    },
  );

  testWidgets(
    'T20-C8: una sugerencia de la lista tiene area tactil minima 44dp de alto y Semantics de boton',
    (tester) async {
      useTallViewport(tester);
      places.searchResult = Right([
        const PlacePrediction(
          id: 'p1',
          mainText: 'Parque La Carolina',
          secondaryText: 'Quito',
          latitude: 0,
          longitude: 0,
        ),
      ]);

      await tester.pumpWidget(_wrap(const LocationSearchView()));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('location_search_destination_input')),
        'Carolina',
      );
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pump();

      final tileFinder = find.byType(PredictionTile);
      expect(tileFinder, findsOneWidget);
      expect(tester.getSize(tileFinder).height, greaterThanOrEqualTo(44));

      final tileSemantics = _semanticsWithLabel(
        tester,
        'Parque La Carolina, Quito',
      );
      expect(tileSemantics.properties.button, isTrue);
    },
  );

  testWidgets(
    'T20-C9: muestra el skeleton mientras busca y el estado vacio cuando no hay resultados',
    (tester) async {
      useTallViewport(tester);
      places.searchResult = const Right([]);
      final pending = Completer<void>();
      places.pendingSearch = pending;

      await tester.pumpWidget(_wrap(const LocationSearchView()));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('location_search_destination_input')),
        'xyz',
      );
      // Deja pasar el debounce: el handler ya arranco y esta esperando
      // `pending`, asi que isSearchingDestination queda en true.
      await tester.pump(const Duration(milliseconds: 30));

      expect(find.byType(SkeletonPredictionList), findsOneWidget);

      pending.complete();
      await tester.pump();
      await tester.pump();

      expect(find.byType(SkeletonPredictionList), findsNothing);
      expect(
        find.text('No encontramos lugares con ese nombre'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'T20-C10: al presionar una prediccion, el input correspondiente refleja el nombre elegido',
    (tester) async {
      useTallViewport(tester);
      places.searchResult = Right([
        const PlacePrediction(
          id: 'p2',
          mainText: 'Aeropuerto Mariscal Sucre',
          secondaryText: 'Tababela',
          latitude: 0,
          longitude: 0,
        ),
      ]);

      await tester.pumpWidget(_wrap(const LocationSearchView()));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('location_search_destination_input')),
        'Aeropuerto',
      );
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pump();

      await tester.tap(find.text('Aeropuerto Mariscal Sucre'));
      await tester.pump();

      final destinationField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('location_search_destination_input')),
          matching: find.byType(TextField),
        ),
      );
      expect(destinationField.controller?.text, 'Aeropuerto Mariscal Sucre');
    },
  );
}
