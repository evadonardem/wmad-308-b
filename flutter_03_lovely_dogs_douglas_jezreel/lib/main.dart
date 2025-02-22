import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:english_words/english_words.dart';

void main() {
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
            seedColor: const Color.fromARGB(255, 255, 182, 193)),
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
  late Future<List<String>> futureBreeds;
  Future<Dog>? futureSelectedDog;
  bool hasSelection = false;
  var wordPair = "";

  @override
  void initState() {
    super.initState();
    futureBreeds = fetchBreeds();
  }

  void handleBreedSelection(String breed) async {
    setState(() {
      wordPair = WordPair.random().join("");
      hasSelection = true;
    });

    final selectedDog = await fetchRandomDogFromBreed(breed, wordPair);
    setState(() {
      futureSelectedDog = Future.value(selectedDog);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE4E1), Color(0xFFFFC0CB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Select a Dog Breed",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              FutureBuilder<List<String>>(
                  future: futureBreeds,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      var breeds = snapshot.data!;
                      return SizedBox(
                        width: 200,
                        child: DropdownButton<String>(
                          value: null,
                          hint: const Text("Select Breed"),
                          items: breeds
                              .map((breed) => DropdownMenuItem(
                                  value: breed,
                                  child: Text(breed.toUpperCase())))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) handleBreedSelection(value);
                          },
                        ),
                      );
                    }
                    return const Text("No breeds found.");
                  }),
              if (hasSelection && futureSelectedDog != null)
                FutureBuilder<Dog>(
                    future: futureSelectedDog,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      } else if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                width: 300,
                                height: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    snapshot.data!.imageUrl,
                                    width: 300,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                snapshot.data!.name.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    }),
            ],
          ),
        ),
      ),
    );
  }
}

class Dog {
  final String breed;
  final String imageUrl;
  final String name;

  Dog({required this.breed, required this.imageUrl, required this.name});

  factory Dog.fromJson(String breed, String imageUrl, String name) {
    return Dog(breed: breed, imageUrl: imageUrl, name: name);
  }
}

Future<List<String>> fetchBreeds() async {
  final dogBreedsEndpoint = 'https://dog.ceo/api/breeds/list/all';
  final response = await http.get(Uri.parse(dogBreedsEndpoint));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<String>.from(data['message'].keys);
  } else {
    throw Exception('Failed to fetch breeds');
  }
}

Future<Dog> fetchRandomDogFromBreed(String breed, String name) async {
  final dogImageEndpoint = 'https://dog.ceo/api/breed/$breed/images/random';
  final response = await http.get(Uri.parse(dogImageEndpoint));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return Dog.fromJson(breed, data['message'], name);
  } else {
    throw Exception('Failed to fetch image from breed');
  }
}
