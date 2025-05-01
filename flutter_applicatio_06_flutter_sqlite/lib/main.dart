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
  databaseFactory = databaseFactoryFfi;
  WidgetsFlutterBinding.ensureInitialized();

  final dbPath = await getDatabasesPath();
  print("wmad-308-b Database path: $dbPath");

  final dbName = 'wmad-308-b_doggie_database.db';
  final db = openDatabase(
    join(await getDatabasesPath(), dbName),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT, photo TEXT)',
      );
    },
    version: 1,
  );

  Future<void> insertDog(Dog dog) async {
    final database = await db;
    await database.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  for (var i = 0; i < 100; i++) {
    final dogName = WordPair.random().asPascalCase;
    var dog = Dog(
      name: dogName,
      breed: "askal",
      photo: "http://some-url/$dogName$i.jpg",
    );
    await insertDog(dog);
  }

  Future<List<Dog>> fetchDogs() async {
    final database = await db;

    final List<Map<String, Object?>> dogMaps = await database.query('dogs');
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

  List<Dog> adoptedDogs = await fetchDogs();
  print("wmad-308-b My adopted dogs count ${adoptedDogs.length}");

  print(await fetchDogs());

  Future<void> updateDog(Dog dog) async {
    final database = await db;

    await database.update(
      'dogs',
      dog.toMap(),
      where: 'id = ?',
      whereArgs: [dog.id],
    );
  }

  adoptedDogs.shuffle();
  Dog luckyDog = adoptedDogs.first;
  print("You're the lucky one to change your name: ${luckyDog.name}");
  luckyDog.name = "Orocan";
  print("Your new
