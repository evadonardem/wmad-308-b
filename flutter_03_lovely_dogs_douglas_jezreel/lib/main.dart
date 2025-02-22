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
      title: 'Lovely Dogs by Jezreel Douglas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 18, 28, 83)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Lovely Dogs by Jezreel Douglas'),
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
  late Future<List<Breed>> futureBreeds;
  Future<BreedImage>? futureSelectedImageUrl;
  bool hasSelection = false;
  var wordPair = "";

  @override
  void initState() {
    super.initState();
    futureBreeds = fetchBreeds();
  }

  void handleBreedSelection(Breed breed) {
    setState(() {
      wordPair = WordPair.random().join("");
      hasSelection = true;
      futureSelectedImageUrl = fetchRandomAnimalFromBreed(breed.name);
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
            colors: [Color(0xFFB2FEFA), Color.fromARGB(255, 159, 100, 255)],
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
              FutureBuilder<List<Breed>>(
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
                        child: DropdownMenu(
                          dropdownMenuEntries: breeds
                              .map((breed) => DropdownMenuEntry(
                                  value: breed, label: breed.name.toUpperCase()))
                              .toList(),
                          onSelected: (value) {
                            if (value != null) handleBreedSelection(value);
                          },
                        ),
                      );
                    }
                    return const Text("No breeds found.");
                  }),
              if (hasSelection && futureSelectedImageUrl != null)
                FutureBuilder<BreedImage>(
                    future: futureSelectedImageUrl,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      } else if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
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
                        );
                      }
                      return const SizedBox();
                    }),
              Text(
                wordPair.toUpperCase(),
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Breed {
  final String name;

  Breed({required this.name});

  factory Breed.fromJson(String name) {
    return Breed(name: name);
  }
}

class BreedImage {
  final String imageUrl;

  BreedImage({required this.imageUrl});

  factory BreedImage.fromJson(Map<String, dynamic> json) {
    return BreedImage(imageUrl: json['message']);
  }
}

Future<List<Breed>> fetchBreeds() async {
  final dogBreedsEndpoint = 'https://dog.ceo/api/breeds/list/all';
  final response = await http.get(Uri.parse(dogBreedsEndpoint));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<Breed> breeds =
        List.from(data['message'].keys.map((name) => Breed.fromJson(name)));
    return breeds;
  } else {
    throw Exception('Failed to fetch breeds');
  }
}

Future<BreedImage> fetchRandomAnimalFromBreed(String breed) async {
  final dogBreedsEndpoint = 'https://dog.ceo/api/breed/$breed/images/random';
  final response = await http.get(Uri.parse(dogBreedsEndpoint));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return BreedImage.fromJson(data);
  } else {
    throw Exception('Failed to fetch image from breed');
  }
}
