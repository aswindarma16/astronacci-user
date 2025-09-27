import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../globals.dart';

class UserDatabase {
  static Database? _db;

  static Future<Database> _init() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "users.db");

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            userName TEXT PRIMARY KEY,
            profilePictureFilePath TEXT
          )
        ''');
      },
    );

    return _db!;
  }

  static Future<int> insertUser(User user) async {
    final db = await _init();
    return await db.insert(
      "users",
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  static Future<List<User>> loadUsersPaged({
    required int offset,
  }) async {
    final db = await _init();
    final maps = await db.query(
      "users",
      limit: limitDataPerLoad,
      offset: offset,
    );
    return maps.map((e) => User.fromJson(e)).toList();
  }

  static Future<String?> loadUserProfilePictureFilePath(String userName) async {
    try {
      final db = await _init();
      final maps = await db.query(
        "users",
        columns: ["profilePictureFilePath"],
        where: "userName = ?",
        whereArgs: [userName],
      );

      if (maps.isNotEmpty) {
        return maps.first["profilePictureFilePath"] as String?;
      }
      return null;
    } catch (e) {
      return generalErrorMessage;
    }
  }

  static Future<String> saveUserProfilePicture({
    required String userName,
    required String? profilePictureFilePath,
  }) async {
    try {
      final db = await _init();
      final count = await db.update(
        "users",
        {"profilePictureFilePath": profilePictureFilePath},
        where: "userName = ?",
        whereArgs: [userName],
      );

      if (count == 0) {
        return "No user found!";
      }
      return "success";
    } catch (e) {
      return generalErrorMessage;
    }
  }

  static Future<List<User>> searchUsersByUserName({
    required String keyword,
    required int offset,
  }) async {
    final db = await _init();
    final maps = await db.query(
      "users",
      where: "userName LIKE ?",
      whereArgs: ['%$keyword%'],
      limit: limitDataPerLoad,
      offset: offset,
    );

    return maps.map((e) => User.fromJson(e)).toList();
  }

}
