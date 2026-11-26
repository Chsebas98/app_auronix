// Smoke test real sobre un átomo ya existente del design system (AppButton), reemplazando el
// smoke test de contador que dejaba `flutter create` por defecto y que probaba una pantalla que
// ya no existe en la app real (ver docs/architecture/existing_foundation.md, Tarea 0).

import 'package:auronix_app/app/design/theme/app_theme.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppButton renderiza su label y dispara onPressed al tocarlo', (
    WidgetTester tester,
  ) async {
    var pressed = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, _) => MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Continuar',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Continuar'), findsOneWidget);
    expect(pressed, isFalse);

    await tester.tap(find.text('Continuar'));
    await tester.pump();

    expect(pressed, isTrue);
  });
}
