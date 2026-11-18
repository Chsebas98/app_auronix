// Confirma el contenido real de la configuracion de CI/documentacion de T4 (ver
// .github/workflows/ci.yml y README.md), no solo que existan los archivos.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'T4-C6: ci.yml define checkout, setup de Flutter, analyze y test --coverage',
    () {
      final content = File('.github/workflows/ci.yml').readAsStringSync();

      expect(content, contains('actions/checkout'));
      expect(content, contains('subosito/flutter-action'));
      expect(content, contains('flutter analyze'));
      expect(content, contains('flutter test --coverage'));
    },
  );

  test(
    'T4-C7: README.md documenta instalacion, variables de entorno, ejecucion por ambiente y testing',
    () {
      final content = File('README.md').readAsStringSync();

      expect(content, contains('.env.example'));
      expect(content, contains('main_dev.dart'));
      expect(content, contains('main_prod.dart'));
      expect(content, contains('flutter test'));
      expect(content, contains('flutter pub get'));
    },
  );

  test(
    'T4-C8: analysis_options.yaml activa flutter_lints de verdad (declarado en pubspec.yaml)',
    () {
      final analysisOptions = File('analysis_options.yaml').readAsStringSync();
      expect(
        analysisOptions,
        contains('include: package:flutter_lints/flutter.yaml'),
      );

      final pubspec = File('pubspec.yaml').readAsStringSync();
      final devDependenciesIndex = pubspec.indexOf('dev_dependencies:');
      final flutterLintsIndex = pubspec.indexOf('flutter_lints:');
      final nextTopLevelKeyIndex = pubspec.indexOf(
        RegExp(r'\n[A-Za-z_]+:'),
        devDependenciesIndex + 'dev_dependencies:'.length,
      );

      // flutter_lints debe estar DENTRO de dev_dependencies, no en otro bloque
      // (ver PR #18: antes quedaba anidado dentro de flutter_launcher_icons y
      // nunca se instalaba de verdad).
      expect(flutterLintsIndex, greaterThan(devDependenciesIndex));
      expect(flutterLintsIndex, lessThan(nextTopLevelKeyIndex));
    },
  );
}
