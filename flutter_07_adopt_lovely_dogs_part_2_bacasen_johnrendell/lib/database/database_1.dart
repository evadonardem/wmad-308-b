import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await getDatabasesPath();
    print("Database path: $dbPath");
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        breed TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        isAdopted INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<int> insertDog(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(
      'dogs',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> queryDogs({required bool isAdopted}) async {
    final db = await instance.database;
    return await db.query('dogs', where: 'isAdopted = ?', whereArgs: [isAdopted ? 1 : 0]);
  }

  Future<List<Map<String, dynamic>>> queryAllDogs() async {
    final db = await instance.database;
    return await db.query('dogs');
  }

  Future<int> updateDog(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update(
      'dogs',
      row,
      where: 'id = ?',
      whereArgs: [id],
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}