// Prueba la logica de habilitacion/carga del boton de login (T13) de forma
// pura, sin montar el arbol completo de widgets: AppCheckbox/AppTextField
// activan un arbol de semantica que choca con un bug conocido del framework
// de pruebas de Flutter (node.parent?._dirty) ante pumps sucesivos — la
// logica de decision en si (la parte que de verdad pide T13) se prueba aqui
// directamente sobre AuthFormState/AuthUnifiedState reales.

import 'package:auronix_app/app/network/error_mapper.dart';
import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auronix_app/features/auth/presentation/molecules/login_button_signals.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isClientLoginDisabled', () {
    test('T13-C1 T13-C3: deshabilitado con email invalido', () {
      const state = AuthFormState(
        email: 'no-es-un-correo',
        password: 'contrasenaValida1',
      );
      expect(isClientLoginDisabled(state, const AuthUnifiedIdle()), isTrue);
    });

    test('T13-C1 T13-C3: deshabilitado con contraseña demasiado corta', () {
      const state = AuthFormState(email: 'valido@test.com', password: 'corta1');
      expect(isClientLoginDisabled(state, const AuthUnifiedIdle()), isTrue);
    });

    test('T13-C1 T13-C3: habilitado cuando email y contraseña son validos', () {
      const state = AuthFormState(
        email: 'valido@test.com',
        password: 'contrasenaValida1',
      );
      expect(isClientLoginDisabled(state, const AuthUnifiedIdle()), isFalse);
    });

    test(
      'T13-C4 T13-C6: deshabilitado mientras hay un login en curso, aunque el formato sea valido',
      () {
        const state = AuthFormState(
          email: 'valido@test.com',
          password: 'contrasenaValida1',
        );
        expect(
          isClientLoginDisabled(state, const AuthUnifiedLoading()),
          isTrue,
        );
      },
    );
  });

  group('isDriverLoginDisabled', () {
    test('T13-C1 T13-C3: deshabilitado con CI/pasaporte invalido', () {
      const state = AuthFormState(
        ciPassport: '',
        password: 'contrasenaValida1',
      );
      expect(isDriverLoginDisabled(state, const AuthUnifiedIdle()), isTrue);
    });

    test('T13-C1 T13-C3: habilitado cuando CI y contraseña son validos', () {
      const state = AuthFormState(
        ciPassport: '1234567890',
        password: 'contrasenaValida1',
      );
      expect(isDriverLoginDisabled(state, const AuthUnifiedIdle()), isFalse);
    });

    test('T13-C4 T13-C6: deshabilitado mientras hay un login en curso', () {
      const state = AuthFormState(
        ciPassport: '1234567890',
        password: 'contrasenaValida1',
      );
      expect(isDriverLoginDisabled(state, const AuthUnifiedLoading()), isTrue);
    });
  });

  test(
    'T13-C4 T13-C6: isAuthLoginInProgress solo es verdadero en AuthUnifiedLoading',
    () {
      expect(isAuthLoginInProgress(const AuthUnifiedLoading()), isTrue);
      expect(isAuthLoginInProgress(const AuthUnifiedIdle()), isFalse);
      expect(
        isAuthLoginInProgress(
          const AuthUnifiedFailure(failure: AuthFailure(message: 'x')),
        ),
        isFalse,
      );
    },
  );

  test(
    'T13-C5: el mensaje de un login fallido (401) es legible, sin trazas ni datos internos',
    () {
      final options = RequestOptions(path: '/api/v1/auth/login');
      final failure = ErrorMapper.fromDioException(
        DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 401),
        ),
      );

      // Lo que AuthUnifiedFailure(failure: ...) le pasaria a
      // DialogCubit.showMessage(message: failure.message) en auth_page.dart.
      expect(failure.message, isNot(contains('DioException')));
      expect(failure.message, isNot(contains('Exception')));
      expect(failure.message, isNotEmpty);
    },
  );
}
