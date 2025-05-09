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
      title: 'Lovely Dogs',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 20, 83, 18)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Lovely Dogs by Depaynos, Nathalie'),
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
      wordPair = WordPair.random().asUpperCase;
      hasSelection = true;
      futureSelectedImageUrl = fetchRandomAnimalFromBreed(breed.name);
    });
  }

//build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side (Text & Dropdown)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Select a dog breed:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Center(
                    child: FutureBuilder<List<Breed>>(
                      future: futureBreeds,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        } else if (snapshot.hasData &&
                            snapshot.data!.isNotEmpty) {
                          var breeds = snapshot.data!;
                          return DropdownMenu(
                            dropdownMenuEntries: breeds
                                .map((breed) => DropdownMenuEntry(
                                    value: breed,
                                    label: breed.name.toUpperCase()))
                                .toList(),
                            onSelected: (value) {
                              if (value != null) handleBreedSelection(value);
                            },
                          );
                        }
                        return const Text("No breeds found.");
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Name: ",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Center(
                    child: Text(
                      wordPair.toUpperCase(),
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ],
              ),
            ),

            // Right Side (Image)
            if (hasSelection && futureSelectedImageUrl != null)
              Expanded(
                child: FutureBuilder<BreedImage>(
                  future: futureSelectedImageUrl,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    } else if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                          snapshot.data!.imageUrl,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DogData {
  final String breedName;
  final String dogName;
  final String imgUrl;

  const DogData({required this.breedName, required this.dogName, required this.imgUrl});

  factory DogData.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'breedName': String breedName, 'dogName': String dogName, 'imgUrl': String imgUrl} =>
        DogData(breedName: breedName, dogName: dogName, imgUrl: imgUrl),
      _ => throw const FormatException('Failed to load data.'),
    };
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
