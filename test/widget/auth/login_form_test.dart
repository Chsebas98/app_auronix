// Prueba la validacion reactiva del boton de login (T13-C1/C3) contra los
// widgets reales (ClientLoginForm/DriverLoginForm) y los Cubits/Blocs reales
// (AuthFormCubit, AuthUnifiedBloc) — no un fake del formulario.
//
// AppTextField (input_default) arma su propio arbol de MergeSemantics/
// Semantics/ExcludeSemantics, que choca con un bug conocido del framework de
// pruebas de Flutter ante pumps sucesivos ("node.parent?._dirty != true").
// Se envuelve el arbol en ExcludeSemantics para evitarlo, igual que en otra
// sesion con este mismo widget.
//
// El caso de carga (T13-C4/C6, boton deshabilitado+spinner mientras
// AuthUnifiedLoading) se prueba de forma pura en login_button_signals_test.dart:
// el procesamiento async real del Bloc (on<Event> corre en un microtask del
// stream interno, no sincronicamente con add()) es una carrera genuina
// dentro del entorno fake-async de flutter_test, nada ganado reproduciendola
// aqui sobre el arbol completo de widgets.

import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auronix_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auronix_app/features/auth/presentation/molecules/client/client_login_form.dart';
import 'package:auronix_app/features/auth/presentation/molecules/driver/driver_login_form.dart';
import 'package:auronix_app/shared/atoms/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class _NoopAuthRepository implements AuthUnifiedRepository {
  @override
  Future<dynamic> noSuchMethod(Invocation invocation) async => null;
}

class _FakeSharedPreferences implements SharedPreferences {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _wrap({
  required AuthFormCubit formCubit,
  required AuthUnifiedBloc authBloc,
  required Widget child,
}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: ExcludeSemantics(
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: formCubit),
              BlocProvider.value(value: authBloc),
            ],
            child: Form(key: GlobalKey<FormState>(), child: child),
          ),
        ),
      ),
    ),
  );
}

void main() {
  late AuthFormCubit formCubit;
  late AuthUnifiedBloc authBloc;

  setUp(() {
    formCubit = AuthFormCubit(
      prefs: RxSharedPreferences(_FakeSharedPreferences()),
    );
    authBloc = AuthUnifiedBloc(
      repository: _NoopAuthRepository(),
      prefs: RxSharedPreferences(_FakeSharedPreferences()),
    );
  });

  tearDown(() async {
    await formCubit.close();
    await authBloc.close();
  });

  testWidgets(
    'T13-C1 T13-C3: el boton de login de cliente esta deshabilitado hasta que el email y la contraseña son validos',
    (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        _wrap(
          formCubit: formCubit,
          authBloc: authBloc,
          child: ClientLoginForm(formKey: formKey),
        ),
      );

      expect(
        tester.widget<AppButton>(find.byType(AppButton)).isDisabled,
        isTrue,
      );

      formCubit.changeEmail('valido@test.com');
      formCubit.changePassword('contrasenaValida1');
      await tester.pump();
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).isDisabled,
        isFalse,
      );
    },
  );

  testWidgets(
    'T13-C1 T13-C3: el boton de login de conductor esta deshabilitado hasta que CI y contraseña son validos',
    (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        _wrap(
          formCubit: formCubit,
          authBloc: authBloc,
          child: DriverLoginForm(formKey: formKey),
        ),
      );

      expect(
        tester.widget<AppButton>(find.byType(AppButton)).isDisabled,
        isTrue,
      );

      formCubit.changeCiPassport('1234567890');
      formCubit.changePassword('contrasenaValida1');
      await tester.pump();
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).isDisabled,
        isFalse,
      );
    },
  );
}
