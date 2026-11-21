// Prueba FareEstimateCard (T21): desglose de distancia/duracion/precio,
// skeleton mientras calcula, estado de error con reintento y el boton de
// confirmar ruta.

import 'package:auronix_app/app/design/theme/app_theme.dart';
import 'package:auronix_app/features/home/domain/entities/fare_estimate.dart';
import 'package:auronix_app/features/home/domain/entities/route_info.dart';
import 'package:auronix_app/features/home/presentation/widgets/fare_estimate_card.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:auronix_app/shared/atoms/skeleton/app_skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    ),
  );
}

const _route = RouteInfo(
  points: [],
  distanceMeters: 10000,
  durationSeconds: 1200,
  polylineEncoded: '',
);
const _fare = FareEstimate(
  estimatedPrice: 5.50,
  currency: 'USD',
  baseFare: 1.00,
  distanceFare: 3.50,
  timeFare: 1.00,
);

void main() {
  testWidgets(
    'T21-C9: muestra el desglose de distancia, duracion y precio estimado',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          FareEstimateCard(
            routeInfo: _route,
            fareEstimate: _fare,
            onConfirm: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('10.0 km'), findsOneWidget);
      expect(find.text('20 min'), findsOneWidget);
      expect(find.text('\$5.50'), findsOneWidget);
    },
  );

  testWidgets(
    'T21-C9: muestra un skeleton mientras la tarifa se esta calculando',
    (tester) async {
      await tester.pumpWidget(
        _wrap(const FareEstimateCard(isLoading: true, onConfirm: _noop)),
      );
      await tester.pump();

      expect(find.byType(AppSkeletonBox), findsWidgets);
      expect(find.text('--'), findsNothing);
    },
  );

  testWidgets(
    'T21-C10: al presionar Confirmar ruta con datos validos, invoca el callback',
    (tester) async {
      var confirmed = false;
      await tester.pumpWidget(
        _wrap(
          FareEstimateCard(
            routeInfo: _route,
            fareEstimate: _fare,
            onConfirm: () => confirmed = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('fare_estimate_card_confirm_button')),
      );
      await tester.pump();

      expect(confirmed, isTrue);
    },
  );

  testWidgets(
    'el boton de confirmar queda deshabilitado mientras calcula o si hay error',
    (tester) async {
      final buttonFinder = find.byKey(
        const Key('fare_estimate_card_confirm_button'),
      );

      await tester.pumpWidget(
        _wrap(const FareEstimateCard(isLoading: true, onConfirm: _noop)),
      );
      await tester.pump();
      expect(tester.widget<AppButton>(buttonFinder).isDisabled, isTrue);

      await tester.pumpWidget(
        _wrap(
          const FareEstimateCard(
            errorMessage: 'No se pudo calcular la ruta',
            onConfirm: _noop,
          ),
        ),
      );
      await tester.pump();
      expect(tester.widget<AppButton>(buttonFinder).isDisabled, isTrue);

      await tester.pumpWidget(
        _wrap(
          FareEstimateCard(
            routeInfo: _route,
            fareEstimate: _fare,
            onConfirm: () {},
          ),
        ),
      );
      await tester.pump();
      expect(tester.widget<AppButton>(buttonFinder).isDisabled, isFalse);
    },
  );

  testWidgets(
    'T21-C11: en caso de error muestra el mensaje y un boton para reintentar sin cerrar la vista',
    (tester) async {
      var retried = false;
      await tester.pumpWidget(
        _wrap(
          FareEstimateCard(
            errorMessage: 'No se pudo calcular la ruta',
            onRetry: () => retried = true,
            onConfirm: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('No se pudo calcular la ruta'), findsOneWidget);
      final retryFinder = find.byKey(
        const Key('fare_estimate_card_retry_button'),
      );
      expect(retryFinder, findsOneWidget);

      await tester.tap(retryFinder);
      await tester.pump();

      expect(retried, isTrue);
      // La vista sigue mostrando la tarjeta (no se cierra nada al reintentar).
      expect(find.byType(FareEstimateCard), findsOneWidget);
    },
  );
}

void _noop() {}
