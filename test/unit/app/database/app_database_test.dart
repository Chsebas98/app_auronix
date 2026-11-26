// Prueba AppDatabase (T9) contra sqflite real (sqflite_common_ffi), incluida
// una migracion de verdad v3 -> v4: se crea un archivo .db con el esquema v3
// (solo "user", como ya existia antes de T9) y se le pide a AppDatabase que
// lo abra en version 4 — eso dispara su onUpgrade real, no uno simulado.

import 'dart:io';

import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/db_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Datos de prueba deliberadamente ficticios (T9-C5): ningun campo aqui
/// corresponde a una persona, cedula, email o telefono real.
Map<String, Object?> mockTripRow({int passengerId = 999001}) => {
  DbConstants.colCodigoViaje: 'TEST0001',
  DbConstants.colPassengerId: passengerId,
  DbConstants.colDriverId: 999002,
  DbConstants.colCooperativaId: 1,
  DbConstants.colOrigenLatitud: -0.1807,
  DbConstants.colOrigenLongitud: -78.4678,
  DbConstants.colOrigenDireccion: 'Direccion de prueba 123',
  DbConstants.colDestinoLatitud: -0.2,
  DbConstants.colDestinoLongitud: -78.5,
  DbConstants.colDestinoDireccion: 'Otra direccion de prueba 456',
  DbConstants.colDistanciaKm: 5.2,
  DbConstants.colPrecioTotal: 3.5,
  DbConstants.colEstado: 'COMPLETADO',
  DbConstants.colFechaSolicitud: '2026-01-01T00:00:00Z',
};

Future<String> _dbFilePath() async {
  final dir = await getDatabasesPath();
  return p.join(dir, DbConstants.dbName);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.instance;
    await db.close();
    final path = await _dbFilePath();
    if (await File(path).exists()) await File(path).delete();
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'T9-C1 T9-C3 T9-C6: inicializa trip_cache con su llave primaria e indices, sin romper "user"',
    () async {
      final conn = await db.database;

      final tables = await conn.query(
        'sqlite_master',
        columns: ['name'],
        where: "type = 'table' AND name IN (?, ?)",
        whereArgs: [DbConstants.tableUser, DbConstants.tableTripCache],
      );
      expect(
        tables.map((r) => r['name']),
        containsAll([DbConstants.tableUser, DbConstants.tableTripCache]),
      );

      final pk = await conn.rawQuery(
        "PRAGMA table_info(${DbConstants.tableTripCache})",
      );
      final pkColumn = pk.firstWhere((c) => c['pk'] == 1);
      expect(pkColumn['name'], DbConstants.colId);

      final indexes = await conn.rawQuery(
        "PRAGMA index_list(${DbConstants.tableTripCache})",
      );
      expect(indexes, isNotEmpty);
    },
  );

  test(
    'T9-C7: guarda y consulta un borrador de viaje creado sin conexion',
    () async {
      await db.database;
      final id = await db.saveTripDraft(mockTripRow());

      final pending = await db.getPendingDrafts();
      expect(pending, hasLength(1));
      expect(pending.first[DbConstants.colId], id);
      expect(pending.first[DbConstants.colRemoteId], isNull);
      expect(pending.first[DbConstants.colSynced], 0);
      expect(pending.first[DbConstants.colCodigoViaje], 'TEST0001');
    },
  );

  test(
    'T9-C1: CRUD basico — cachear, consultar y borrar un viaje confirmado por el backend',
    () async {
      await db.database;
      final id = await db.cacheTrip(mockTripRow(), remoteId: 555);

      var cached = await db.getCachedTrips(passengerId: 999001);
      expect(cached, hasLength(1));
      expect(cached.first[DbConstants.colRemoteId], 555);
      expect(cached.first[DbConstants.colSynced], 1);

      // cacheTrip con el mismo remoteId actualiza, no duplica.
      await db.cacheTrip({
        ...mockTripRow(),
        DbConstants.colEstado: 'CANCELADO',
      }, remoteId: 555);
      cached = await db.getCachedTrips(passengerId: 999001);
      expect(cached, hasLength(1));
      expect(cached.first[DbConstants.colEstado], 'CANCELADO');

      await db.deleteTripCacheRow(id);
      cached = await db.getCachedTrips(passengerId: 999001);
      expect(cached, isEmpty);
    },
  );

  test(
    'T9-C5: los datos de prueba son ficticios, no informacion real de produccion',
    () {
      final row = mockTripRow();
      final values = row.values.map((v) => v.toString()).join(' ');

      expect(values, isNot(contains('@'))); // ningun email real
      expect(
        RegExp(r'\b\d{10}\b').hasMatch(values),
        isFalse,
        reason: 'no debe parecer una cedula ecuatoriana real (10 digitos)',
      );
      expect(row[DbConstants.colOrigenDireccion], contains('prueba'));
    },
  );

  test(
    'T9-C2 T9-C4: la migracion v3 -> v4 agrega trip_cache sin perder los usuarios ya guardados',
    () async {
      // 1. Crear un archivo .db "viejo" (version 3: solo "user", igual que
      //    antes de esta tarea) e insertar un usuario real de esa version.
      final path = await _dbFilePath();
      final oldDb = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: (conn, version) async {
            await conn.execute('''
              CREATE TABLE ${DbConstants.tableUser} (
                ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
                ${DbConstants.colUserType} TEXT NOT NULL,
                ${DbConstants.colTokenAccess} TEXT NOT NULL,
                ${DbConstants.colTokenRefresh} TEXT,
                ${DbConstants.colRole} TEXT NOT NULL,
                ${DbConstants.colFirstName} TEXT NOT NULL,
                ${DbConstants.colLastName} TEXT NOT NULL,
                ${DbConstants.colCreatedAt} INTEGER
              );
            ''');
          },
        ),
      );
      await oldDb.insert(DbConstants.tableUser, {
        DbConstants.colUserType: DbConstants.userTypeClient,
        DbConstants.colTokenAccess: 'old-token-pre-migracion',
        DbConstants.colRole: 'rolUser',
        DbConstants.colFirstName: 'Usuario',
        DbConstants.colLastName: 'Viejo',
        DbConstants.colCreatedAt: 1,
      });
      await oldDb.close();

      // 2. Pedirle a AppDatabase (version 4 real) que abra ese mismo
      //    archivo — dispara su onUpgrade(3, 4) de verdad.
      final upgraded = await db.database;

      final users = await upgraded.query(DbConstants.tableUser);
      expect(users, hasLength(1));
      expect(
        users.first[DbConstants.colTokenAccess],
        'old-token-pre-migracion',
      );

      final tripCacheExists = await upgraded.query(
        'sqlite_master',
        where: "type = 'table' AND name = ?",
        whereArgs: [DbConstants.tableTripCache],
      );
      expect(tripCacheExists, isNotEmpty);

      // Y la tabla nueva ya funciona normalmente tras la migracion.
      await db.saveTripDraft(mockTripRow());
      expect(await db.getPendingDrafts(), hasLength(1));
    },
  );
}
