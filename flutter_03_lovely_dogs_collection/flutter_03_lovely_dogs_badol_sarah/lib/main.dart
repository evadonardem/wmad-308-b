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
      title: 'Lovely Dogs By Sarah Badol',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(150, 255, 175, 175)),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const MyHomePage(title: 'Lovely Dogs'),
    const AdoptedDogsPage(),
    const NotAdoptedDogsPage(),
    const AboutPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Adopted'),
          BottomNavigationBarItem(icon: Icon(Icons.pets_outlined), label: 'Not Adopted'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
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
  late BreedDog selectedBreedDog;

  @override
  void initState() {
    super.initState();
    futureBreeds = fetchBreeds();
    selectedBreedDog = BreedDog(name: "", breed: Breed(name: ""), image: Future.value(BreedImage(imageUrl: "")));
  }

  void handleBreedSelection(Breed breed) {
    setState(() {
      final wordPair = WordPair.random().join("");
      futureSelectedImageUrl = fetchRandomAnimalFromBreed(breed.name);
      hasSelection = true;
      selectedBreedDog = BreedDog(
        name: wordPair,
        breed: breed,
        image: futureSelectedImageUrl!,
      );
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
                    return DropdownButton<Breed>(
                      value: breeds.first,
                      items: breeds
                          .map((breed) => DropdownMenuItem(
                              value: breed, child: Text(breed.name.toUpperCase())))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) handleBreedSelection(value);
                      },
                    );
                  }
                  return const Text("No breeds found.");
                }),
            if (hasSelection)
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
                        child: Image.network(
                          snapshot.data!.imageUrl,
                          height: 300,
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
            Text(
              selectedBreedDog.name.toUpperCase(),
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              selectedBreedDog.breed.name.toUpperCase(),
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}

// Adopted Dogs Page
class AdoptedDogsPage extends StatelessWidget {
  const AdoptedDogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adopted Dogs')),
      body: const Center(child: Text('List of Adopted Dogs')),
    );
  }
}

// Not Adopted Dogs Page
class NotAdoptedDogsPage extends StatelessWidget {
  const NotAdoptedDogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Adopted Dogs')),
      body: const Center(child: Text('List of Not Adopted Dogs')),
    );
  }
}

// About Page
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Center(child: Text('Information about this app')),
    );
  }
}

class BreedDog {
  final String name;
  final Breed breed;
  final Future<BreedImage> image;

  BreedDog({required this.name, required this.breed, required this.image});
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
  final response = await http.get(Uri.parse('https://dog.ceo/api/breeds/list/all'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List.from(data['message'].keys.map((name) => Breed.fromJson(name)));
  } else {
    throw Exception('Failed to fetch breeds');
  }
}

Future<BreedImage> fetchRandomAnimalFromBreed(String breed) async {
  final response = await http.get(Uri.parse('https://dog.ceo/api/breed/$breed/images/random'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return BreedImage.fromJson(data);
  } else {
    throw Exception('Failed to fetch image from breed');
  }
}
