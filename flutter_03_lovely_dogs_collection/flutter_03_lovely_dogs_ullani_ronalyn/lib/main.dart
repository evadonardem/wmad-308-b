import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:english_words/english_words.dart';

void main() {
  runApp(const MyApp());
}


class Album {
  final int userId;
  final int id;
  final String title;

  const Album({required this.userId, required this.id, required this.title});
}

class DogBreed {
  final String name;

  const DogBreed({required this.name});

  factory DogBreed.fromJson(Map<String, dynamic> json) {
    return DogBreed(
      name: json['name'] as String,
    );
  }
}

Future<List<DogBreed>> fetchDogBreeds() async {
  var dogBreedsAPI = 'https://dog.ceo/api/breeds/list/all';
  final response = await http.get(Uri.parse(dogBreedsAPI));

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    var breeds = (data['message'] as Map<String, dynamic>).keys.map(
      (key) => DogBreed(name: key),
    ).toList();
    return breeds;
  } else {
    throw Exception('Failed to load dog breeds');
  }
}

Future<String> fetchBreedImage(String breed) async {
  var breedImageAPI = 'https://dog.ceo/api/breed/$breed/images/random';
  final response = await http.get(Uri.parse(breedImageAPI));

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data['message'];
  } else {
    throw Exception('Failed to load breed image');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ullani Dog Breed Selector',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 81, 133, 229)),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      home: const MyHomePage(title: 'Ullani Dog Breed Selector'),
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
  late Future<List<DogBreed>> futureDogBreeds;
  DogBreed? selectedBreed;
  String? breedImageUrl;
  String? dogName;

  @override
  void initState() {
    super.initState();
    futureDogBreeds = fetchDogBreeds();
    dogName = _generateRandomName();  
  }


  String _generateRandomName() {
    WordPair randomPair = generateWordPairs().take(1).first;
    return randomPair.asPascalCase;
  }

  void _onBreedChanged(DogBreed? newBreed) async {
    setState(() {
      selectedBreed = newBreed;
      breedImageUrl = null;
      dogName = _generateRandomName(); 
    });

    if (newBreed != null) {
      try {
        String imageUrl = await fetchBreedImage(newBreed.name);
        setState(() {
          breedImageUrl = imageUrl;
        });
      } catch (e) {
        setState(() {
          breedImageUrl = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 80, 154, 223),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 155, 203, 252), const Color.fromARGB(255, 84, 147, 223)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FutureBuilder<List<DogBreed>>(
                  future: futureDogBreeds,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      return Card(
                        elevation: 10,
                        shadowColor: const Color.fromARGB(255, 95, 153, 241),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              DropdownButton<DogBreed>(
                                value: selectedBreed,
                                hint: const Text(
                                  'Select a breed',
                                  style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 82, 82, 82)),
                                ),
                                items: snapshot.data!.map((DogBreed breed) {
                                  return DropdownMenuItem<DogBreed>(
                                    value: breed,
                                    child: Text(
                                      breed.name,
                                      style: const TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                                  );
                                }).toList(),
                                onChanged: _onBreedChanged,
                                isExpanded: true,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                dropdownColor: Colors.white,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color.fromARGB(255, 65, 110, 217),
                                ),
                                iconSize: 30,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const Text('No data available');
                    }
                  },
                ),
                const SizedBox(height: 20),
                if (selectedBreed != null)
                  Card(
                    elevation: 10,
                    shadowColor: const Color.fromARGB(255, 77, 193, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Selected Breed: ${selectedBreed!.name}\nDog Name: $dogName',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 58, 183, 137),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (breedImageUrl != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        breedImageUrl!,
                        fit: BoxFit.cover,
                        height: 250,
                        width: 250,
                      ),
                    ),
                  ),
                if (breedImageUrl == null && selectedBreed != null)
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}