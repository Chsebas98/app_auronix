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
          // Migración de v1 a v2
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

          // Renombrar columna token -> token_access
          await db.execute('''
            CREATE TABLE user_new (
              ${DbConstants.colId} INTEGER PRIMARY KEY CHECK (${DbConstants.colId} = ${DbConstants.singleUserId}),
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
            INSERT INTO user_new 
            SELECT 
              id, token, NULL, role, username, first_name, second_name,
              last_name, second_last_name, email, photo_url, is_google_user,
              NULL, NULL
            FROM ${DbConstants.tableUser};
          ''');

          await db.execute('DROP TABLE ${DbConstants.tableUser}');
          await db.execute(
            'ALTER TABLE user_new RENAME TO ${DbConstants.tableUser}',
          );
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.tableUser} (
        ${DbConstants.colId} INTEGER PRIMARY KEY CHECK (${DbConstants.colId} = ${DbConstants.singleUserId}),
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
  }

  Future<void> upsertUserMap(Map<String, Object?> data) async {
    final db = await database;

    final row = <String, Object?>{
      ...data,
      DbConstants.colId: DbConstants.singleUserId,
      DbConstants.colCreatedAt: DateTime.now().millisecondsSinceEpoch,
    };

    await db.insert(
      DbConstants.tableUser,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, Object?>?> getUserMap() async {
    final db = await database;
    final rows = await db.query(
      DbConstants.tableUser,
      where: '${DbConstants.colId} = ?',
      whereArgs: [DbConstants.singleUserId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  /// ✅ NUEVO: Actualizar solo tokens
  Future<void> updateTokens({
    required String tokenAccess,
    required String tokenRefresh,
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
      where: '${DbConstants.colId} = ?',
      whereArgs: [DbConstants.singleUserId],
    );
  }

  /// ✅ NUEVO: Obtener refresh token
  Future<String?> getRefreshToken() async {
    final db = await database;
    final rows = await db.query(
      DbConstants.tableUser,
      columns: [DbConstants.colTokenRefresh],
      where: '${DbConstants.colId} = ?',
      whereArgs: [DbConstants.singleUserId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first[DbConstants.colTokenRefresh] as String?;
  }

  /// ✅ NUEVO: Obtener access token
  Future<String?> getAccessToken() async {
    final db = await database;
    final rows = await db.query(
      DbConstants.tableUser,
      columns: [DbConstants.colTokenAccess],
      where: '${DbConstants.colId} = ?',
      whereArgs: [DbConstants.singleUserId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first[DbConstants.colTokenAccess] as String?;
  }

  Future<void> clearUser() async {
    final db = await database;
    await db.delete(
      DbConstants.tableUser,
      where: '${DbConstants.colId} = ?',
      whereArgs: [DbConstants.singleUserId],
    );
  }

  Future<void> close() async {
    final db = _db;
    _db = null;
    if (db != null) await db.close();
  }
}
