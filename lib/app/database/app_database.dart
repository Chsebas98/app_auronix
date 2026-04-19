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
  }

  Future<void> upsertUserMap(
    Map<String, Object?> data,
    String userType,
  ) async {
    final db = await database;

    final row = <String, Object?>{
      ...data,
      DbConstants.colUserType: userType,
      DbConstants.colCreatedAt: DateTime.now().millisecondsSinceEpoch,
    };

    await db.insert(
      DbConstants.tableUser,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
