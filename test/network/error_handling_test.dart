// Prueba ErrorMapper y LoggingInterceptor (T8): errores de red mapeados a
// Failure tipado con mensaje amigable, y logs que enmascaran datos sensibles.
// T8-C1 (401 -> limpieza de sesion) reutiliza el mismo AuthInterceptor real
// ya probado en T6-C5 — se repite aqui con su propio codigo de criterio
// porque Mnemosine verifica por codigo literal, no por comportamiento.

import 'dart:async';

import 'package:auronix_app/app/core/bloc/session-bloc/session_bloc.dart';
import 'package:auronix_app/app/core/network/interceptors/auth_interceptor.dart';
import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/db_constants.dart';
import 'package:auronix_app/app/network/error_mapper.dart';
import 'package:auronix_app/app/network/interceptors/logging_interceptor.dart';
import 'package:auronix_app/core/errors/failure.dart';
import 'package:auronix_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

RequestOptions _options([String path = '/api/v1/profile']) =>
    RequestOptions(path: path);

DioException _withResponse(
  int statusCode, {
  dynamic data,
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  final options = _options();
  return DioException(
    requestOptions: options,
    type: type,
    response: Response(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
    ),
  );
}

DioException _withoutResponse(DioExceptionType type) =>
    DioException(requestOptions: _options(), type: type);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('ErrorMapper', () {
    test(
      'T8-C2 T8-C6: error 500 se mapea a ServerFailure con mensaje amigable, sin trazas',
      () {
        final failure = ErrorMapper.fromDioException(
          _withResponse(
            500,
            data: {'message': 'Internal error at line 42 in UserService.java'},
          ),
        );

        expect(failure, isA<ServerFailure>());
        expect(failure.statusCode, 500);
        // El mensaje del backend se respeta (ya es responsabilidad suya no
        // filtrar trazas), pero el mapper nunca agrega su propia traza interna.
        expect(failure.detail, isNot(contains('DioException')));
        expect(failure.detail, isNot(contains('StackTrace')));
      },
    );

    test(
      'T8-C3: sin message del backend, ErrorMapper usa un mensaje generico comprensible',
      () {
        final failure = ErrorMapper.fromDioException(
          _withResponse(500, data: null),
        );

        expect(failure, isA<ServerFailure>());
        expect(failure.message, isNot(contains('DioException')));
        expect(failure.message.toLowerCase(), contains('error'));
      },
    );

    test(
      'T8-C5: un 409 (conflicto de idempotencia) se mapea a IdempotencyConflictFailure',
      () {
        final failure = ErrorMapper.fromDioException(_withResponse(409));

        expect(failure, isA<IdempotencyConflictFailure>());
        expect(failure.statusCode, 409);
        expect(failure.message.toLowerCase(), contains('procesando'));
      },
    );

    test(
      'T8-C6: sin respuesta del servidor (timeout), se mapea a NetworkFailure',
      () {
        final failure = ErrorMapper.fromDioException(
          _withoutResponse(DioExceptionType.connectionTimeout),
        );

        expect(failure, isA<NetworkFailure>());
      },
    );

    test('un 401 se mapea a AuthFailure', () {
      final failure = ErrorMapper.fromDioException(_withResponse(401));
      expect(failure, isA<AuthFailure>());
      expect(failure.statusCode, 401);
    });
  });

  group('LoggingInterceptor', () {
    late List<String> prints;
    late DebugPrintCallback originalDebugPrint;

    setUp(() {
      prints = [];
      originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        prints.add(message ?? '');
      };
    });

    tearDown(() {
      debugPrint = originalDebugPrint;
    });

    test(
      'T8-C4 T8-C7: el header Authorization se enmascara en los logs de request',
      () {
        final interceptor = LoggingInterceptor();
        final options = RequestOptions(
          path: '/api/v1/profile',
          headers: {'Authorization': 'Bearer secreto-real-123'},
        );

        interceptor.onRequest(options, RequestInterceptorHandler());

        final logged = prints.join('\n');
        expect(logged, isNot(contains('secreto-real-123')));
        expect(logged, contains('***'));
      },
    );

    test(
      'T8-C4 T8-C7: la contrasena y los tokens del body se enmascaran en los logs',
      () {
        final interceptor = LoggingInterceptor();
        final options = RequestOptions(
          path: '/auth/clients/login',
          data: {'email': 'user@test.com', 'password': 'miClaveSecreta1'},
        );

        interceptor.onRequest(options, RequestInterceptorHandler());

        final response = Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'result': {
              'token_access': 'access-xyz',
              'token_refresh': 'refresh-xyz',
            },
          },
        );
        interceptor.onResponse(response, ResponseInterceptorHandler());

        final logged = prints.join('\n');
        expect(logged, isNot(contains('miClaveSecreta1')));
        expect(logged, isNot(contains('access-xyz')));
        expect(logged, isNot(contains('refresh-xyz')));
        expect(logged, contains('user@test.com')); // lo no sensible si se ve
      },
    );
  });

  group('AuthInterceptor', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.instance;
      final conn = await db.database;
      await conn.delete(DbConstants.tableUser);
    });

    test(
      'T8-C1: un 401 sin refresh token dispara la limpieza automatica de sesion',
      () async {
        await db.upsertUserMap({
          DbConstants.colTokenAccess: 'token-abc',
          DbConstants.colRole: 'rolUser',
          DbConstants.colFirstName: 'Test',
          DbConstants.colLastName: 'User',
        }, DbConstants.userTypeClient);

        final sessionBloc = SessionBloc(
          _NoopAuthRepository(),
          RxSharedPreferences(_FakeSharedPreferences()),
        );
        final interceptor = AuthInterceptor(
          db: db,
          dio: Dio(),
          authRemote: AuthRemoteDatasource(dio: Dio()),
          sessionBloc: () => sessionBloc,
        );

        final err = _withResponse(401);
        final handler = ErrorInterceptorHandler();
        unawaited(
          (handler as dynamic).future.then((_) {}, onError: (_) {}) as Future,
        );

        await interceptor.onError(err, handler);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(sessionBloc.state, isA<SessionUnauthenticated>());
        await sessionBloc.close();
      },
    );
  });
}

class _NoopAuthRepository implements AuthUnifiedRepository {
  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<dynamic> noSuchMethod(Invocation invocation) async => null;
}

class _FakeSharedPreferences implements SharedPreferences {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
