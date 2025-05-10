import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Dog {
  final int? id;
  String name;
  String breed;
  String photo;

  Dog({this.id, required this.name, required this.breed, required this.photo});

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'breed': breed, 'photo': photo};
  }

  @override
  String toString() {
    return 'Dog{id: $id, name: $name, breed: $breed, photo : $photo}';
  }
}

void main() async {
  //initialization
  databaseFactory = databaseFactoryFfi;
  WidgetsFlutterBinding.ensureInitialized();

  //open/create database (DONE)
  final databasePath = await getDatabasesPath();

  print("wmad-308-b database path: $databasePath");

  final databaseName = 'wmad-308-b_doggie_database.db';
  final database = openDatabase(
    join(databasePath, databaseName),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE dogs(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, breed TEXT, photo TEXT)',
      );
    },

    version: 1,
  );

  /**
   * CRUD
   * C - reate
   * R - ead
   * U - pdate
   * D - elete
   */

  // C - reate (DONE)
  Future<void> insertDog(Dog dog) async {
    final db = await database;
    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  for (var i = 0; i < 100; i++) {
    final myAdoptedDogName = WordPair.random().asPascalCase;
    final myAdoptedDog = Dog(
      name: myAdoptedDogName,
      breed: "Shitzu",
      photo: "https://some-url/$myAdoptedDogName$i.jpg",
    );
    insertDog(myAdoptedDog);
  }

  //R -ead
  Future<List<Dog>> dogs() async {

    final db = await database;
    final List<Map<String, Object?>> dogMaps = await db.query('dogs');
    return [
      for (
        final {
          'id': id as int, 
          'name': name as String, 
          'breed': breed as String,
          'photo': photo as String
          } in dogMaps
          ) Dog(id: id, name: name, breed: breed, photo: photo),
    ];
  }

  //Sample code retrieving all of my adopted dogs from the database
  List<Dog> myAdoptedDogs = await dogs();
  print("wmad-308-b list of my adopted dogs: ${myAdoptedDogs.length}");

  //U - pdate
  Future<void> updateDog(Dog dog) async {
  final db = await database;
  await db.update(
    'dogs',
    dog.toMap(),
    where: 'id = ?',
    whereArgs: [dog.id],
  );
}

  myAdoptedDogs.shuffle();
  Dog myLuckyDog = myAdoptedDogs.first;
  print("Your the lucky one to change your name: $myLuckyDog");
  myLuckyDog.name = "shaboingboing";
  print("Your New name is ${myLuckyDog.name}");
  updateDog(myLuckyDog);
  print("Your name is officially registered!");

  // D - elete
  Future<void> deleteDog(int? id) async {
    final db = await database;
    await db.delete(
      'dogs', where: 
      'id = ?', 
      whereArgs: [id]
    );
  }

  // Sample code to delete dog in my adopted dogs
  myAdoptedDogs.shuffle();
  Dog myUnLuckyDog = myAdoptedDogs.first;
  print("You're so unlucky today: $myUnLuckyDog");
  deleteDog(myUnLuckyDog.id);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}