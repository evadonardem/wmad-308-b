import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_helper.dart';

/// Initializes the database and ensures it's created
Future<void> initDatabase() async {
  // Initialize FFI for sqflite if needed
  sqfliteFfiInit();
  
  // Create database helper instance to ensure database is created
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database; // This will create the database if it doesn't exist
}

/// Resets the database by dropping and recreating the table
/// Use with caution as this will delete all data
Future<void> resetDatabase() async {
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.recreateDB();
}