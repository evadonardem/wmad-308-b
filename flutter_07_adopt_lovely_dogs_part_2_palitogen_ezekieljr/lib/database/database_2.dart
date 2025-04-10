import 'database_1.dart';

Future<void> initDatabase() async {
  await DatabaseHelper.instance.database;
}
