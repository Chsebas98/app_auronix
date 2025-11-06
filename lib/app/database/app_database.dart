import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  Future<Database> _openDatabase() async {
    final dataBasePath = await getDatabasesPath();
    final path = join(dataBasePath, 'auronix_db.db');

    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE user (id INTEGER PRIMARY_KEY, name TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> addData() async {
    final dataBase = await _openDatabase();
    await dataBase.insert('user', {
      'name': 'sebas',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await dataBase.close();
  }

  Future<void> showData() async {
    final dataBase = await _openDatabase();
    // final data = await dataBase.query('user');
    await dataBase.close();
  }
}
