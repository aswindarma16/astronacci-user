import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SearchHistoryDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'search_history.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            keyword TEXT UNIQUE
          )
        ''');
      },
    );
  }

  static Future<void> addKeyword(String keyword) async {
    final db = await database;
    await db.insert(
      'history',
      {'keyword': keyword},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<String>> getHistory() async {
    final db = await database;
    final result = await db.query('history', orderBy: 'id DESC');
    return result.map((e) => e['keyword'] as String).toList();
  }

  static Future<void> deleteKeyword(String keyword) async {
    final db = await database;
    await db.delete('history', where: 'keyword = ?', whereArgs: [keyword]);
  }

  static Future<void> clearHistory() async {
    final db = await database;
    await db.delete('history');
  }
}