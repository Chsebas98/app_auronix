// Prueba AuthInterceptor (contra una AppDatabase real, via sqflite_common_ffi,
// no un fake) e IdempotencyInterceptor, los dos interceptores de T6.

import 'dart:async';

import 'package:auronix_app/app/core/bloc/session-bloc/session_bloc.dart';
import 'package:auronix_app/app/core/network/interceptors/auth_interceptor.dart';
import 'package:auronix_app/app/core/network/interceptors/idempotency_interceptor.dart';
import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/db_constants.dart';
import 'package:auronix_app/core/errors/failure.dart';
import 'package:auronix_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:auronix_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.instance;
    // Limpia cualquier usuario de un test anterior en el mismo proceso.
    final conn = await db.database;
    await conn.delete(DbConstants.tableUser);
  });

  group('AuthInterceptor', () {
    Future<void> seedActiveUser({required String accessToken}) {
      return db.upsertUserMap({
        DbConstants.colTokenAccess: accessToken,
        DbConstants.colTokenRefresh: 'refresh-token',
        DbConstants.colRole: 'rolUser',
        DbConstants.colFirstName: 'Test',
        DbConstants.colLastName: 'User',
      }, DbConstants.userTypeClient);
    }

    AuthInterceptor buildInterceptor({SessionBloc? sessionBloc}) {
      return AuthInterceptor(
        db: db,
        dio: Dio(),
        authRemote: AuthRemoteDatasource(dio: Dio()),
        sessionBloc: () =>
            sessionBloc ??
            SessionBloc(
              _NoopAuthRepository(),
              RxSharedPreferences(_FakeSharedPreferences()),
            ),
      );
    }

    test(
      'T6-C1 T6-C3 T6-C6: agrega Authorization Bearer cuando hay token activo',
      () async {
        await seedActiveUser(accessToken: 'token-abc');
        final interceptor = buildInterceptor();
        final options = RequestOptions(path: '/api/v1/profile');
        final handler = RequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(options.headers['Authorization'], 'Bearer token-abc');
      },
    );

    test(
      'T6-C5: ante 401 sin refresh token disponible, emite LoggoutUserEvent al bus de sesion',
      () async {
        await seedActiveUser(accessToken: 'token-abc');
        final conn = await db.database;
        await conn.update(
          DbConstants.tableUser,
          {DbConstants.colTokenRefresh: null},
          where: '${DbConstants.colUserType} = ?',
          whereArgs: [DbConstants.userTypeClient],
        );

        final sessionBloc = SessionBloc(
          _NoopAuthRepository(),
          RxSharedPreferences(_FakeSharedPreferences()),
        );
        final interceptor = buildInterceptor(sessionBloc: sessionBloc);

        final err = DioException(
          requestOptions: RequestOptions(path: '/api/v1/profile'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/profile'),
            statusCode: 401,
          ),
        );
        final handler = ErrorInterceptorHandler();
        // AuthInterceptor.onError termina con handler.next(err), que completa
        // el Future interno del handler CON error (asi dio sigue propagando
        // el 401 al caller real) — sin un listener se reporta como "unhandled"
        // en este test aislado, que no representa un caller real de dio.
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

  group('IdempotencyInterceptor', () {
    test(
      'T6-C2 T6-C4 T6-C7 T23-C3: POST a /api/v1/trips recibe un X-Idempotency-Key UUID v4 unico',
      () {
        final interceptor = IdempotencyInterceptor();
        const uuidV4Pattern =
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$';

        final optionsA = RequestOptions(path: '/api/v1/trips', method: 'POST');
        final optionsB = RequestOptions(path: '/api/v1/trips', method: 'POST');
        interceptor.onRequest(optionsA, RequestInterceptorHandler());
        interceptor.onRequest(optionsB, RequestInterceptorHandler());

        final keyA = optionsA.headers['X-Idempotency-Key'] as String?;
        final keyB = optionsB.headers['X-Idempotency-Key'] as String?;

        expect(keyA, matches(uuidV4Pattern));
        expect(keyB, matches(uuidV4Pattern));
        expect(keyA, isNot(keyB));
        // El backend real (micro-auronix IdempotencyFilter) solo reconoce el
        // header con prefijo 'X-' — sin prefijo el filtro lo ignora por
        // completo y la idempotencia queda rota en silencio.
        expect(optionsA.headers['Idempotency-Key'], isNull);
      },
    );

    test(
      'IdempotencyInterceptor no agrega el header en peticiones GET ni en otras rutas',
      () {
        final interceptor = IdempotencyInterceptor();
        final getOptions = RequestOptions(path: '/api/v1/trips', method: 'GET');
        final otherPostOptions = RequestOptions(
          path: '/api/v1/profile',
          method: 'POST',
        );

        interceptor.onRequest(getOptions, RequestInterceptorHandler());
        interceptor.onRequest(otherPostOptions, RequestInterceptorHandler());

        expect(getOptions.headers['X-Idempotency-Key'], isNull);
        expect(otherPostOptions.headers['X-Idempotency-Key'], isNull);
      },
    );
  });
}

/// AuthUnifiedRepository falso solo para poder construir un SessionBloc real
/// en el test sin levantar toda la app — SessionBloc.logout() delega en el
/// repositorio, que aqui no hace nada (no es lo que se esta probando).
class _NoopAuthRepository implements AuthUnifiedRepository {
  // logout() se usa de verdad en el flujo de T6-C5 (SessionBloc.logout()
  // lo espera) y declara Future<Either<Failure, void>>, no dynamic: pasar
  // por noSuchMethod aqui lanza un TypeError de cast en tiempo de ejecucion
  // (Future<dynamic> no es Future<Either<Failure, void>>), asi que se
  // sobreescribe explicitamente.
  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<dynamic> noSuchMethod(Invocation invocation) async => null;
}

class _FakeSharedPreferences implements SharedPreferences {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
