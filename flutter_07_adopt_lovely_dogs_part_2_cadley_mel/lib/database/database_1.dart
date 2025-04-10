import 'package:sqflite/sqflite.dart';
import 'database.dart';

Future<void> initDatabase() async {
  await DatabaseHelper.instance.database;
}