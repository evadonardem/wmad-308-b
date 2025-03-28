import 'package:flutter/material.dart';

import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:english_words/english_words.dart';

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
    return 'Dog{id: $id, name: $name, breed: $breed}';
  }
}

Future<void> main() async {
  databaseFactory = databaseFactoryFfi;
  WidgetsFlutterBinding.ensureInitialized();

  final databasePath = await getDatabasesPath();
  print("wmad-308-b Database path: $databasePath");

  final databaseName = 'wmad-308-b_doggie_database.db';
  final database = openDatabase(
    join(await getDatabasesPath(), databaseName),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT, photo TEXT)',
      );
    },
    version: 1,
  );

  /**
   * CRUD
   * C-reate
   * R-ead
   * U-pdate
   * D-elete
   */

// C -reate (Done)
  Future<void> insertDog(Dog dog) async {
    final db = await database;

    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  for (var i = 0; i < 100; i++) {
    final myadoptedDogName = WordPair.random().asPascalCase;
    var myadoptedDog = Dog(
        name: myadoptedDogName,
        breed: "askal",
        photo: "http://some-url/$myadoptedDogName$i.jpg");
    await insertDog(myadoptedDog);
  }

  // R -ead (Done)
  Future<List<Dog>> dogs() async {
    final db = await database;

    final List<Map<String, Object?>> dogMaps = await db.query('dogs');
    return [
      for (final {
            'id': id as int,
            'name': name as String,
            'breed': breed as String,
            'photo': photo as String
          } in dogMaps)
        Dog(id: id, name: name, breed: breed, photo: photo),
    ];
  }

// sample code retrieve all my adopted dogs from the database
  List<Dog> myAdoptedDogs = await dogs();
  print("wmad-308-b My adopted dogs count ${myAdoptedDogs.length}");

  List<Dog> myadoptedDogs = await dogs();
  print(await dogs());

  Future<void> updateDog(Dog dog) async {
    final db = await database;

    await db.update(
      'dogs',
      dog.toMap(),
      where: 'id = ?',
      whereArgs: [dog.id],
    );
  }

// U -pdate (Done)
  myadoptedDogs.shuffle();
  Dog myluckyDog = myadoptedDogs.first;
  print("Your the lucky one to change your name: ${myluckyDog.name}");
  myluckyDog.name = "Orocan";
  print("Your new name is ${myluckyDog.name}");
  updateDog(myluckyDog);
  print("Your new name has officially registered");


  // D -elete (Done)
  Future<void> deleteDog(int? id) async {
    final db = await database;

    await db.delete(
      'dogs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // sample code to delete in my adopted dogs
  myadoptedDogs.shuffle();
  Dog unluckyDog = myadoptedDogs.first;
  print("Your so unlucky ${unluckyDog.name}");
  deleteDog(unluckyDog.id!);
  print("Your are now the appetizer of the day");


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
        useMaterial3: true,
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
            const Text(
              'You have pushed the button this many times:',
            ),
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