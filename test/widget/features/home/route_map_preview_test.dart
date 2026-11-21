// Prueba RouteMapPreview (T21). GoogleMap es una vista de plataforma nativa:
// se verifica que el widget se construye con los marcadores/polilinea
// correctos inspeccionando sus propiedades directamente (no hay
// onMapCreated real en flutter_test sin integration_test). El calculo del
// bounding box de la camara se prueba aparte, como funcion pura.

import 'package:auronix_app/features/home/presentation/widgets/route_map_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('computeRouteBounds (T21-C8)', () {
    test('encuadra origen y destino cuando no hay puntos de ruta', () {
      final bounds = computeRouteBounds(
        origin: const LatLng(-0.18, -78.47),
        destination: const LatLng(-0.20, -78.50),
      );

      expect(bounds.southwest.latitude, -0.20);
      expect(bounds.southwest.longitude, -78.50);
      expect(bounds.northeast.latitude, -0.18);
      expect(bounds.northeast.longitude, -78.47);
    });

    test(
      'se expande para incluir puntos de ruta fuera del segmento origen-destino',
      () {
        final bounds = computeRouteBounds(
          origin: const LatLng(0, 0),
          destination: const LatLng(1, 1),
          routePoints: const [LatLng(0.5, -2), LatLng(3, 0.5)],
        );

        expect(bounds.southwest.latitude, 0);
        expect(bounds.southwest.longitude, -2);
        expect(bounds.northeast.latitude, 3);
        expect(bounds.northeast.longitude, 1);
      },
    );
  });

  testWidgets(
    'T21-C8: renderiza los marcadores de origen y destino y la polilinea recibida',
    (tester) async {
      const origin = LatLng(-0.18, -78.47);
      const destination = LatLng(-0.20, -78.50);
      const routePoints = [origin, LatLng(-0.19, -78.48), destination];

      await tester.pumpWidget(
        const MaterialApp(
          home: RouteMapPreview(
            origin: origin,
            destination: destination,
            routePoints: routePoints,
          ),
        ),
      );
      await tester.pump();

      final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(map.markers, hasLength(2));
      final originMarker = map.markers.firstWhere(
        (m) => m.markerId.value == 'route_preview_origin',
      );
      expect(originMarker.position, origin);
      final destinationMarker = map.markers.firstWhere(
        (m) => m.markerId.value == 'route_preview_destination',
      );
      expect(destinationMarker.position, destination);

      expect(map.polylines, hasLength(1));
      expect(map.polylines.first.points, routePoints);
    },
  );

  testWidgets('sin puntos de ruta, no dibuja ninguna polilinea', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RouteMapPreview(origin: LatLng(0, 0), destination: LatLng(1, 1)),
      ),
    );
    await tester.pump();

    final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(map.polylines, isEmpty);
  });
}
