import 'package:flutter/material.dart';

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
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
  //open//create database
  databaseFactory = databaseFactoryFfi;
  WidgetsFlutterBinding.ensureInitialized();

  final databasePath = await getDatabasesPath();
  print("wmad-308-b database path: $databasePath");

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

  //C- Create

  Future<void> insertDog(Dog dog) async {
    final db = await database;

    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  for (var i = 0; i < 10; i++) {
    final myAdoptedDogName = WordPair.random().asPascalCase;
    var myAdoptedDog = Dog(
      name: myAdoptedDogName,
      breed: "askal",
      photo: "http://some-url/$myAdoptedDogName$i.jpg",
    );

    await insertDog(myAdoptedDog);
  }

  //R-Read
  Future<List<Dog>> dogs() async {
    final db = await database;

    final List<Map<String, Object?>> dogMaps = await db.query('dogs');
    return [
      for (final {
            'id': id as int,
            'name': name as String,
            'breed': breed as String,
            'photo': photo as String,
          }
          in dogMaps)
        Dog(id: id, name: name, breed: breed, photo: photo),
    ];
  }

  List<Dog> myAdoptedDog = await dogs();
  print(await dogs());

  //U-Update
  Future<void> updateDog(Dog dog) async {
    final db = await database;
    await db.update('dogs', 
    dog.toMap(), 
    where: 'id = ?', 
    whereArgs: [dog.id]
    );
  }

  myAdoptedDog.shuffle();
  Dog myluckyDog = myAdoptedDog.first;
  print("Your Lucky dog name : ${myluckyDog.name}");
  myluckyDog.name = "Dinosaur";
  print("Lucky dog's new name : ${myluckyDog.name}");
  updateDog(myluckyDog);
  print("Your new name has officially registered");


//D-Delete
  Future<void> deleteDog(int id) async {
    final db = await database;
    await db.delete('dogs', 
    where: 'id = ?', 
    whereArgs: [id]
    );
  }

  myAdoptedDog.shuffle();
  Dog myunluckyDog = myAdoptedDog.first;
  print("You're so unlucky : ${myunluckyDog.name}");
  deleteDog(myunluckyDog.id!);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 209, 245),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SQLite by Anasan Genaro'),
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