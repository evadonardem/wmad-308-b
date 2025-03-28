import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dogs.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        breed TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        adoptedDate TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertDog(Map<String, dynamic> dog) async {
    final db = await instance.database;
    return await db.insert('dogs', dog);
  }

  Future<List<Map<String, dynamic>>> queryAllDogs() async {
    final db = await instance.database;
    return await db.query('dogs');
  }

  Future<int> updateDog(Map<String, dynamic> dog) async {
    final db = await instance.database;
    return await db.update(
      'dogs',
      dog,
      where: 'id = ?',
      whereArgs: [dog['id']],
    );
  }

  Future<int> deleteDog(int id) async {
    final db = await instance.database;
    return await db.delete(
      'dogs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }

  Future<void> recreateDB() async {
    final db = await instance.database;
    await db.execute('DROP TABLE IF EXISTS dogs');
    await _createDB(db, 1);
  }
}