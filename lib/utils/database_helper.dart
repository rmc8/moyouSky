import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "moyouSky.db";
  static const _databaseVersion = 1;

  static const table = 'login';
  static const columnService = 'service';
  static const columnId = 'id';
  static const columnPassword = 'password';
  static const columnEmail = 'email';
  static const columnHandle = 'handle';
  static const columnDisplayName = 'display_name';
  static const columnAvatarUrl = 'avatar_url';
  static const columnDescription = 'description';
  static const columnFollowersCount = 'followers_count';
  static const columnFollowsCount = 'follows_count';

  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();

  static DatabaseHelper get instance => _instance;

  Database? _database;
  final secureStorage = const FlutterSecureStorage();
  final _keyLifeDuration = const Duration(days: 180);

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database == null || !_database!.isOpen) {
      _database = await _initDatabase();
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String password = await _getPassword();
    String path = join(databasesPath, _databaseName);
    return await openDatabase(
      path,
      password: password,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId TEXT PRIMARY KEY,
            $columnService TEXT NOT NULL,
            $columnPassword TEXT NOT NULL,
            $columnEmail TEXT,
            $columnHandle TEXT,
            $columnDisplayName TEXT, 
            $columnAvatarUrl TEXT,
            $columnDescription TEXT,
            $columnFollowersCount INTEGER,
            $columnFollowsCount INTEGER
          )
          ''');
  }

  Future<String> _getPassword() async {
    final storedPassword = await secureStorage.read(key: 'db_password');
    final storedDateStr = await secureStorage.read(key: 'db_key_date');

    if (storedPassword != null && storedDateStr != null) {
      final storedDate = DateTime.parse(storedDateStr);
      if (DateTime.now().difference(storedDate) < _keyLifeDuration) {
        return storedPassword;
      }
    }

    final newPassword =
        base64Url.encode(List<int>.generate(24, (i) => (33 + i) % 94));
    await secureStorage.write(key: 'db_password', value: newPassword);
    await secureStorage.write(
        key: 'db_key_date', value: DateTime.now().toIso8601String());

    if (storedPassword != null) {
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, _databaseName);
      var db = await openDatabase(path, password: storedPassword);
      await db.execute('PRAGMA rekey = ?', [newPassword]);
      await db.close();
    }

    return newPassword;
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
  }

  Future<void> insertLoginInfo(Map<String, dynamic> loginInfo) async {
    final db = await database;
    await db.insert(table, loginInfo);
  }

  Future<List<Map<String, dynamic>>> getLoginInfo() async {
    final db = await database;
    return await db.query(table);
  }

  Future<void> updateLoginInfo(Map<String, dynamic> loginInfo) async {
    final db = await database;
    await db.update(
      table,
      loginInfo,
      where: '$columnId = ?',
      whereArgs: [loginInfo[columnId]],
    );
  }

  Future<void> deleteLoginInfo(String id) async {
    final db = await database;
    await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getLoginInfoByServiceAndId(
      String service, String id) async {
    final db = await database;
    final result = await db.query(
      table,
      where: '$columnService = ? AND $columnId = ?',
      whereArgs: [service, id],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return {};
  }

  Future<void> updateLoginInfoByHandleAndService(String handle, String service, Map<String, dynamic> loginInfo) async {
    final db = await database;
    await db.update(
      table,
      loginInfo,
      where: '$columnHandle = ? AND $columnService = ?',
      whereArgs: [handle, service],
    );
  }
}
