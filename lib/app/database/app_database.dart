import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'db_constants.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    final db = _db;
    if (db != null) return db;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, DbConstants.dbName);

    return openDatabase(
      path,
      version: DbConstants.dbVersion,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Migración de v1 a v2: agregar columnas y renombrar token -> token_access
          await db.execute(
            'ALTER TABLE ${DbConstants.tableUser} '
            'ADD COLUMN ${DbConstants.colTokenRefresh} TEXT',
          );
          await db.execute(
            'ALTER TABLE ${DbConstants.tableUser} '
            'ADD COLUMN ${DbConstants.colTokenExpiresAt} INTEGER',
          );
          await db.execute(
            'ALTER TABLE ${DbConstants.tableUser} '
            'ADD COLUMN ${DbConstants.colCreatedAt} INTEGER',
          );

          await db.execute('''
            CREATE TABLE user_v2 (
              ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${DbConstants.colTokenAccess} TEXT NOT NULL,
              ${DbConstants.colTokenRefresh} TEXT,
              ${DbConstants.colRole} TEXT NOT NULL,
              ${DbConstants.colUsername} TEXT,
              ${DbConstants.colFirstName} TEXT NOT NULL,
              ${DbConstants.colSecondName} TEXT,
              ${DbConstants.colLastName} TEXT NOT NULL,
              ${DbConstants.colSecondLastName} TEXT,
              ${DbConstants.colEmail} TEXT,
              ${DbConstants.colPhotoUrl} TEXT,
              ${DbConstants.colIsGoogleUser} INTEGER NOT NULL DEFAULT 0,
              ${DbConstants.colTokenExpiresAt} INTEGER,
              ${DbConstants.colCreatedAt} INTEGER
            );
          ''');

          await db.execute('''
            INSERT INTO user_v2
            SELECT
              id, token, NULL, role, username, first_name, second_name,
              last_name, second_last_name, email, photo_url, is_google_user,
              NULL, NULL
            FROM ${DbConstants.tableUser};
          ''');

          await db.execute('DROP TABLE ${DbConstants.tableUser}');
          await db.execute(
            'ALTER TABLE user_v2 RENAME TO ${DbConstants.tableUser}',
          );
        }

        if (oldVersion < 3) {
          // Migración de v2 a v3: agregar columna user_type y cambiar PRIMARY KEY
          // SQLite no permite ALTER COLUMN, así que recreamos la tabla
          await db.execute('''
            CREATE TABLE user_v3 (
              ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${DbConstants.colUserType} TEXT NOT NULL DEFAULT '${DbConstants.userTypeClient}'
                CHECK(${DbConstants.colUserType} IN ('${DbConstants.userTypeClient}', '${DbConstants.userTypeDriver}')),
              ${DbConstants.colTokenAccess} TEXT NOT NULL,
              ${DbConstants.colTokenRefresh} TEXT,
              ${DbConstants.colRole} TEXT NOT NULL,
              ${DbConstants.colUsername} TEXT,
              ${DbConstants.colFirstName} TEXT NOT NULL,
              ${DbConstants.colSecondName} TEXT,
              ${DbConstants.colLastName} TEXT NOT NULL,
              ${DbConstants.colSecondLastName} TEXT,
              ${DbConstants.colEmail} TEXT,
              ${DbConstants.colPhotoUrl} TEXT,
              ${DbConstants.colIsGoogleUser} INTEGER NOT NULL DEFAULT 0,
              ${DbConstants.colTokenExpiresAt} INTEGER,
              ${DbConstants.colCreatedAt} INTEGER,
              UNIQUE(${DbConstants.colEmail}, ${DbConstants.colUserType})
            );
          ''');

          // Determine user_type from the stored role:
          // 'rolDriver' maps to DRIVER; everything else maps to CLIENT.
          await db.execute('''
            INSERT INTO user_v3 (
              ${DbConstants.colUserType},
              ${DbConstants.colTokenAccess},
              ${DbConstants.colTokenRefresh},
              ${DbConstants.colRole},
              ${DbConstants.colUsername},
              ${DbConstants.colFirstName},
              ${DbConstants.colSecondName},
              ${DbConstants.colLastName},
              ${DbConstants.colSecondLastName},
              ${DbConstants.colEmail},
              ${DbConstants.colPhotoUrl},
              ${DbConstants.colIsGoogleUser},
              ${DbConstants.colTokenExpiresAt},
              ${DbConstants.colCreatedAt}
            )
            SELECT
              CASE WHEN ${DbConstants.colRole} = 'rolDriver'
                   THEN '${DbConstants.userTypeDriver}'
                   ELSE '${DbConstants.userTypeClient}'
              END,
              ${DbConstants.colTokenAccess},
              ${DbConstants.colTokenRefresh},
              ${DbConstants.colRole},
              ${DbConstants.colUsername},
              ${DbConstants.colFirstName},
              ${DbConstants.colSecondName},
              ${DbConstants.colLastName},
              ${DbConstants.colSecondLastName},
              ${DbConstants.colEmail},
              ${DbConstants.colPhotoUrl},
              ${DbConstants.colIsGoogleUser},
              ${DbConstants.colTokenExpiresAt},
              ${DbConstants.colCreatedAt}
            FROM ${DbConstants.tableUser};
          ''');

          await db.execute('DROP TABLE ${DbConstants.tableUser}');
          await db.execute(
            'ALTER TABLE user_v3 RENAME TO ${DbConstants.tableUser}',
          );
        }

        if (oldVersion < 4) {
          await _createTripCacheTable(db);
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableUser} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colUserType} TEXT NOT NULL
          CHECK(${DbConstants.colUserType} IN ('${DbConstants.userTypeClient}', '${DbConstants.userTypeDriver}')),
        ${DbConstants.colTokenAccess} TEXT NOT NULL,
        ${DbConstants.colTokenRefresh} TEXT,
        ${DbConstants.colRole} TEXT NOT NULL,
        ${DbConstants.colUsername} TEXT,
        ${DbConstants.colFirstName} TEXT NOT NULL,
        ${DbConstants.colSecondName} TEXT,
        ${DbConstants.colLastName} TEXT NOT NULL,
        ${DbConstants.colSecondLastName} TEXT,
        ${DbConstants.colEmail} TEXT,
        ${DbConstants.colPhotoUrl} TEXT,
        ${DbConstants.colIsGoogleUser} INTEGER NOT NULL DEFAULT 0,
        ${DbConstants.colTokenExpiresAt} INTEGER,
        ${DbConstants.colCreatedAt} INTEGER,
        UNIQUE(${DbConstants.colEmail}, ${DbConstants.colUserType})
      );
    ''');

    await _createTripCacheTable(db);
  }

  /// trip_cache: historial local (copias de viajes ya confirmados por el
  /// backend, synced=1) y borradores offline (creados sin conexion,
  /// synced=0, remote_id nulo hasta que se envien). Alineada con tb_trips.
  Future<void> _createTripCacheTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableTripCache} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colRemoteId} INTEGER,
        ${DbConstants.colCodigoViaje} TEXT,
        ${DbConstants.colPassengerId} INTEGER NOT NULL,
        ${DbConstants.colDriverId} INTEGER,
        ${DbConstants.colCooperativaId} INTEGER,
        ${DbConstants.colOrigenLatitud} REAL NOT NULL,
        ${DbConstants.colOrigenLongitud} REAL NOT NULL,
        ${DbConstants.colOrigenDireccion} TEXT NOT NULL,
        ${DbConstants.colDestinoLatitud} REAL,
        ${DbConstants.colDestinoLongitud} REAL,
        ${DbConstants.colDestinoDireccion} TEXT,
        ${DbConstants.colDistanciaKm} REAL,
        ${DbConstants.colPrecioTotal} REAL,
        ${DbConstants.colEstado} TEXT NOT NULL DEFAULT 'SOLICITADO',
        ${DbConstants.colFechaSolicitud} TEXT,
        ${DbConstants.colSynced} INTEGER NOT NULL DEFAULT 0,
        ${DbConstants.colCachedAt} INTEGER NOT NULL
      );
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_trip_cache_remote_id
        ON ${DbConstants.tableTripCache}(${DbConstants.colRemoteId});
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_trip_cache_passenger
        ON ${DbConstants.tableTripCache}(${DbConstants.colPassengerId});
    ''');
  }

  /// Guarda/actualiza una copia de cache de un viaje ya confirmado por el
  /// backend (synced=1). Si ya existe una fila con el mismo [remoteId], la
  /// reemplaza en vez de duplicarla.
  Future<int> cacheTrip(
    Map<String, Object?> tripData, {
    required int remoteId,
  }) async {
    final db = await database;
    final existing = await db.query(
      DbConstants.tableTripCache,
      columns: [DbConstants.colId],
      where: '${DbConstants.colRemoteId} = ?',
      whereArgs: [remoteId],
      limit: 1,
    );

    final row = <String, Object?>{
      ...tripData,
      DbConstants.colRemoteId: remoteId,
      DbConstants.colSynced: 1,
      DbConstants.colCachedAt: DateTime.now().millisecondsSinceEpoch,
    };

    if (existing.isNotEmpty) {
      final id = existing.first[DbConstants.colId] as int;
      await db.update(
        DbConstants.tableTripCache,
        row,
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
      return id;
    }
    return db.insert(DbConstants.tableTripCache, row);
  }

  /// Guarda un borrador de viaje creado sin conexion (remote_id nulo,
  /// synced=0) para reintentar enviarlo despues.
  Future<int> saveTripDraft(Map<String, Object?> draftData) async {
    final db = await database;
    return db.insert(DbConstants.tableTripCache, {
      ...draftData,
      DbConstants.colRemoteId: null,
      DbConstants.colSynced: 0,
      DbConstants.colCachedAt: DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Historial local (viajes ya confirmados), mas reciente primero.
  Future<List<Map<String, Object?>>> getCachedTrips({int? passengerId}) async {
    final db = await database;
    return db.query(
      DbConstants.tableTripCache,
      where: passengerId != null
          ? '${DbConstants.colSynced} = 1 AND ${DbConstants.colPassengerId} = ?'
          : '${DbConstants.colSynced} = 1',
      whereArgs: passengerId != null ? [passengerId] : null,
      orderBy: '${DbConstants.colCachedAt} DESC',
    );
  }

  /// Borradores pendientes de enviar al backend (sin remote_id todavia).
  Future<List<Map<String, Object?>>> getPendingDrafts() async {
    final db = await database;
    return db.query(
      DbConstants.tableTripCache,
      where: '${DbConstants.colSynced} = 0',
      orderBy: '${DbConstants.colCachedAt} ASC',
    );
  }

  Future<void> deleteTripCacheRow(int id) async {
    final db = await database;
    await db.delete(
      DbConstants.tableTripCache,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearTripCache() async {
    final db = await database;
    await db.delete(DbConstants.tableTripCache);
  }

  Future<void> upsertUserMap(Map<String, Object?> data, String userType) async {
    final db = await database;

    // Garantizar máximo 1 registro por user_type
    await db.delete(
      DbConstants.tableUser,
      where: '${DbConstants.colUserType} = ?',
      whereArgs: [userType],
    );

    final row = <String, Object?>{
      ...data,
      DbConstants.colUserType: userType,
      DbConstants.colCreatedAt: DateTime.now().millisecondsSinceEpoch,
    };

    await db.insert(DbConstants.tableUser, row);
  }

  Future<Map<String, Object?>?> getUserMap(String userType) async {
    final db = await database;
    final rows = await db.query(
      DbConstants.tableUser,
      where: '${DbConstants.colUserType} = ?',
      whereArgs: [userType],
      orderBy: '${DbConstants.colCreatedAt} DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  /// Returns the row for the most recently active user (any user type).
  /// Used by the auth interceptor which operates context-independently.
  Future<Map<String, Object?>?> getActiveUserMap() async {
    final db = await database;
    final rows = await db.query(
      DbConstants.tableUser,
      orderBy: '${DbConstants.colCreatedAt} DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<void> updateTokens({
    required String tokenAccess,
    required String tokenRefresh,
    required String userType,
  }) async {
    final db = await database;
    await db.update(
      DbConstants.tableUser,
      {
        DbConstants.colTokenAccess: tokenAccess,
        DbConstants.colTokenRefresh: tokenRefresh,
        DbConstants.colTokenExpiresAt: DateTime.now()
            .add(const Duration(hours: 1))
            .millisecondsSinceEpoch,
      },
      where: '${DbConstants.colUserType} = ?',
      whereArgs: [userType],
    );
  }

  Future<String?> getRefreshToken(String userType) async {
    final db = await database;
    final rows = await db.query(
      DbConstants.tableUser,
      columns: [DbConstants.colTokenRefresh],
      where: '${DbConstants.colUserType} = ?',
      whereArgs: [userType],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first[DbConstants.colTokenRefresh] as String?;
  }

  Future<String?> getAccessToken(String userType) async {
    final db = await database;
    final rows = await db.query(
      DbConstants.tableUser,
      columns: [DbConstants.colTokenAccess],
      where: '${DbConstants.colUserType} = ?',
      whereArgs: [userType],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first[DbConstants.colTokenAccess] as String?;
  }

  Future<void> clearUser(String userType) async {
    final db = await database;
    await db.delete(
      DbConstants.tableUser,
      where: '${DbConstants.colUserType} = ?',
      whereArgs: [userType],
    );
  }

  Future<void> close() async {
    final db = _db;
    _db = null;
    if (db != null) await db.close();
  }
}
