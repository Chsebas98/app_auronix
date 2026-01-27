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
    final dbPath =
        await getDatabasesPath(); // recomendado :contentReference[oaicite:1]{index=1}
    final path = p.join(dbPath, DbConstants.dbName);

    return openDatabase(
      path,
      version: DbConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DbConstants.tableUser} (
            ${DbConstants.colId} INTEGER PRIMARY KEY CHECK (${DbConstants.colId} = ${DbConstants.singleUserId}),
            ${DbConstants.colToken} TEXT NOT NULL,
            ${DbConstants.colRole} TEXT NOT NULL,
            ${DbConstants.colUsername} TEXT,
            ${DbConstants.colFirstName} TEXT NOT NULL,
            ${DbConstants.colSecondName} TEXT,
            ${DbConstants.colLastName} TEXT NOT NULL,
            ${DbConstants.colSecondLastName} TEXT,
            ${DbConstants.colEmail} TEXT,
            ${DbConstants.colPhotoUrl} TEXT,
            ${DbConstants.colIsGoogleUser} INTEGER NOT NULL DEFAULT 0
          );
        '''); // onCreate/DDL pattern :contentReference[oaicite:2]{index=2}
      },
    );
  }

  // ---- Métodos genéricos SOLO para la tabla "user" como Map ----

  Future<void> upsertUserMap(Map<String, Object?> data) async {
    final db = await database;

    // Fuerza el único registro
    final row = <String, Object?>{
      ...data,
      DbConstants.colId: DbConstants.singleUserId,
    };

    await db.insert(
      DbConstants.tableUser,
      row,
      conflictAlgorithm: ConflictAlgorithm
          .replace, // recomendado :contentReference[oaicite:3]{index=3}
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
