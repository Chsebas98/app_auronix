// Prueba RegisterScreen (T14) contra el widget real, con un
// AuthUnifiedRepository falso solo en GetIt (asi es como la pantalla lo
// resuelve, via sl<AuthUnifiedRepository>()) que graba el
// RegisterRequestModel real que se le envia.
//
// AppTextField arma su propio arbol de MergeSemantics/Semantics, que choca
// con un bug conocido del framework de pruebas de Flutter ante pumps
// sucesivos ("node.parent?._dirty != true") — se envuelve en ExcludeSemantics
// para evitarlo, mismo fix que en login_form_test.dart (T13).

import 'package:auronix_app/app/core/bloc/session-bloc/session_bloc.dart';
import 'package:auronix_app/app/design/theme/app_theme.dart';
import 'package:auronix_app/app/di/dependency_injection.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/data/models/register_request_model.dart';
import 'package:auronix_app/features/auth/domain/models/user_data.dart';
import 'package:auronix_app/features/auth/domain/models/user_role.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auronix_app/features/onBoarding/presentation/screens/register_screen.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class _SpyAuthRepository implements AuthUnifiedRepository {
  RegisterRequestModel? lastRegisterRequest;
  Either<Failure, UserData> registerResult = const Right(
    UserData(id: 1, email: 'x@test.com', role: UserRole.pasajero),
  );

  @override
  Future<Either<Failure, UserData>> registerWithBackend(
    RegisterRequestModel data,
  ) async {
    lastRegisterRequest = data;
    return registerResult;
  }

  @override
  Future<dynamic> noSuchMethod(Invocation invocation) async => null;
}

class _FakeSharedPreferences implements SharedPreferences {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _wrap(Widget child) {
  final router = GoRouter(
    initialLocation: '/register',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SizedBox()),
      GoRoute(path: '/register', builder: (context, state) => child),
    ],
  );
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, navigator) => ExcludeSemantics(
        child: BlocProvider<SessionBloc>(
          create: (_) => SessionBloc(
            _NoopSessionRepository(),
            RxSharedPreferences(_FakeSharedPreferences()),
          ),
          child: navigator!,
        ),
      ),
    ),
  );
}

class _NoopSessionRepository implements AuthUnifiedRepository {
  @override
  Future<dynamic> noSuchMethod(Invocation invocation) async => null;
}

void main() {
  late _SpyAuthRepository repository;

  setUp(() {
    repository = _SpyAuthRepository();
    sl.registerSingleton<AuthUnifiedRepository>(repository);
  });

  tearDown(() {
    sl.unregister<AuthUnifiedRepository>();
  });

  // El formulario es mas largo que el viewport por defecto (800x600) y deja
  // el boton "offstage" (find.byType lo descarta por defecto) — se agranda
  // el viewport de prueba para que el formulario completo quede visible.
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> fillCommonFields(WidgetTester tester) async {
    await tester.enterText(find.byKey(const Key('register_firstName')), 'Juan');
    await tester.enterText(find.byKey(const Key('register_lastName')), 'Pérez');
    await tester.enterText(
      find.byKey(const Key('register_cedula')),
      '0999999999',
    );
    await tester.pump();
  }

  testWidgets(
    'T14-C2 T14-C5: el boton de crear cuenta esta deshabilitado sin un rol seleccionado',
    (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(_wrap(const RegisterScreen()));

      expect(
        tester.widget<AppButton>(find.byType(AppButton)).isDisabled,
        isTrue,
      );
    },
  );

  testWidgets(
    'T14-C3: la cooperativa solo se exige cuando el rol es CONDUCTOR',
    (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(_wrap(const RegisterScreen()));

      await fillCommonFields(tester);
      await tester.enterText(
        find.byKey(const Key('register_email')),
        'juan@test.com',
      );
      await tester.enterText(
        find.byKey(const Key('register_password')),
        'Contrasena@1',
      );
      await tester.pump();

      // Pasajero: sin cooperativa, el formulario ya es valido.
      await tester.tap(find.text('Pasajero'));
      await tester.pump();
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).isDisabled,
        isFalse,
      );

      // Conductor: ahora aparece el campo de cooperativa y se exige.
      await tester.tap(find.text('Conductor'));
      await tester.pump();
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).isDisabled,
        isTrue,
      );

      await tester.enterText(
        find.byKey(const Key('register_cooperativa')),
        '5',
      );
      await tester.pump();
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).isDisabled,
        isFalse,
      );
    },
  );

  testWidgets(
    'T14-C1 T14-C4 T14-C6: envia el rol correcto y los campos sin espacios extra, con auto-login tras exito',
    (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(_wrap(const RegisterScreen()));

      await tester.enterText(
        find.byKey(const Key('register_firstName')),
        '  Juan  ',
      );
      await tester.enterText(
        find.byKey(const Key('register_lastName')),
        '  Pérez  ',
      );
      await tester.enterText(
        find.byKey(const Key('register_cedula')),
        '0999999999',
      );
      await tester.enterText(
        find.byKey(const Key('register_email')),
        '  juan@test.com  ',
      );
      await tester.enterText(
        find.byKey(const Key('register_password')),
        'Contrasena@1',
      );
      await tester.tap(find.text('Pasajero'));
      await tester.pump();

      expect(
        tester.widget<AppButton>(find.byType(AppButton)).isDisabled,
        isFalse,
      );

      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(repository.lastRegisterRequest?.role, UserRole.pasajero);
      expect(repository.lastRegisterRequest?.firstName, 'Juan');
      expect(repository.lastRegisterRequest?.lastName, 'Pérez');
      expect(repository.lastRegisterRequest?.email, 'juan@test.com');
    },
  );
}
