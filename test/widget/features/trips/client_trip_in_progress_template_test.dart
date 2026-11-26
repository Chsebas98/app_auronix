// Prueba la interpolacion de posicion del conductor (T27-C1/C3) y la fila
// de datos del vehiculo (T27-C2/C4) de ClientTripInProgressTemplate.
//
// No se pumpea la pantalla completa (con su GoogleMap real): se confirmo
// con una prueba aislada que, en este entorno de flutter_test, montar un
// GoogleMap real impide que tester.pump() drene CUALQUIER trabajo
// asincrono pendiente — ni siquiera un Future.delayed(Duration.zero) se
// resuelve sin tester.runAsync(), y ademas los BlocBuilder anidados dejan
// de reconstruirse con el estado nuevo del Bloc (aunque bloc.state si
// refleja el valor correcto). Mismo problema de testabilidad que motivo
// la extraccion de computeRouteBounds en T21 — aqui se prueban las dos
// piezas de logica real (LatLngTween, VehicleInfoRow) de forma aislada,
// sin GoogleMap de por medio.

import 'package:auronix_app/app/design/theme/app_theme.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/vehicle_info.dart';
import 'package:auronix_app/features/trips/presentation/templates/client/client_trip_in_progress_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('LatLngTween', () {
    const begin = LatLng(-0.1000, -78.5000);
    const end = LatLng(-0.1050, -78.5050);
    final tween = LatLngTween(begin: begin, end: end);

    test(
      'T27-C1 T27-C3: lerp(0) y lerp(1) devuelven exactamente los extremos',
      () {
        expect(tween.lerp(0), begin);
        expect(tween.lerp(1), end);
      },
    );

    test(
      'T27-C1 T27-C3: lerp(0.5) devuelve el punto medio real, ni el origen ni el destino — el marker interpola en vez de saltar',
      () {
        final midpoint = tween.lerp(0.5);

        expect(midpoint.latitude, closeTo(-0.1025, 1e-9));
        expect(midpoint.longitude, closeTo(-78.5025, 1e-9));
        expect(midpoint, isNot(begin));
        expect(midpoint, isNot(end));
      },
    );

    test(
      'la interpolacion es monotona entre begin y end (sin saltos ni overshoot)',
      () {
        // begin -> end se mueve hacia latitudes/longitudes mas negativas.
        final samples = [0.0, 0.25, 0.5, 0.75, 1.0].map(tween.lerp).toList();
        for (var i = 1; i < samples.length; i++) {
          expect(
            samples[i].latitude,
            lessThanOrEqualTo(samples[i - 1].latitude),
          );
          expect(
            samples[i].longitude,
            lessThanOrEqualTo(samples[i - 1].longitude),
          );
        }
      },
    );
  });

  group('VehicleInfoRow', () {
    Widget wrap(Widget child) => ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: child),
      ),
    );

    testWidgets('T27-C2 T27-C4: muestra placa y modelo del vehiculo asignado', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(VehicleInfoRow(vehicle: VehicleInfo.placeholder())),
      );

      expect(find.textContaining('PBA-1234'), findsOneWidget);
      expect(find.textContaining('Toyota Corolla'), findsOneWidget);
    });

    testWidgets(
      'VehicleInfoRow refleja el VehicleInfo que recibe, no datos fijos propios',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const VehicleInfoRow(
              vehicle: VehicleInfo(
                placa: 'ABC-9999',
                modelo: 'Kia Rio 2020',
                driverName: 'Otro',
              ),
            ),
          ),
        );

        expect(find.textContaining('ABC-9999'), findsOneWidget);
        expect(find.textContaining('Kia Rio 2020'), findsOneWidget);
        expect(find.textContaining('PBA-1234'), findsNothing);
      },
    );
  });
}
