import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class DogBreed {
  final String name;
  const DogBreed({required this.name});

  factory DogBreed.fromJson(String name) {
    return DogBreed(name: name);
  }
}

Future<List<DogBreed>> fetchBreeds() async {
  const url = "https://dog.ceo/api/breeds/list/all";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final breedsMap = data['message'] as Map<String, dynamic>;
    List<DogBreed> breeds =
        breedsMap.keys.map((breed) => DogBreed(name: breed)).toList();

    // Print breeds to console
    for (var breed in breeds) {
      print(breed.name);
    }

    return breeds;
  } else {
    throw Exception('Failed to load breeds');
  }
}

Future<String> fetchBreedImage(String breed) async {
  final url = "https://dog.ceo/api/breed/$breed/images/random";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
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
      title: 'Dog Breeds',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Dog Breeds Selector'),
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
  late Future<List<DogBreed>> futureBreeds;
  String? selectedBreed;
  String? breedImage;

  @override
  void initState() {
    super.initState();
    futureBreeds = fetchBreeds();
  }

  void _onBreedSelected(String? breed) async {
    if (breed != null) {
      final imageUrl = await fetchBreedImage(breed);
      setState(() {
        selectedBreed = breed;
        breedImage = imageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<List<DogBreed>>(
              future: futureBreeds,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No breeds found');
                } else {
                  return Center(
                    child: DropdownButton<String>(
                      hint: const Text('Select a breed'),
                      value: selectedBreed,
                      items:
                          snapshot.data!.map((DogBreed breed) {
                            return DropdownMenuItem<String>(
                              value: breed.name,
                              child: Text(breed.name),
                            );
                          }).toList(),
                      onChanged: _onBreedSelected,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  breedImage != null
                      ? Image.network(
                        breedImage!,
                        width: 400,
                        height: 800,
                        fit: BoxFit.contain,
                      )
                      : const Center(
                        child: Text('Select a breed to see an image'),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}