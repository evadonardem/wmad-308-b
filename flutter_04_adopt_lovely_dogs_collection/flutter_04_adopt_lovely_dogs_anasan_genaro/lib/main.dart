import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class DogBreed {
  final String name;
  const DogBreed({required this.name});

  factory DogBreed.fromJson(String name) {
    return DogBreed(name: name[0].toUpperCase() + name.substring(1));
  }
}

Future<List<DogBreed>> fetchBreeds() async {
  const url = "https://dog.ceo/api/breeds/list/all";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final breedsMap = data['message'] as Map<String, dynamic>;
    return breedsMap.keys.map((breed) => DogBreed(name: breed)).toList();
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
      title: 'Dog Adoption',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 147, 145, 255)),
        primaryColor: const Color.fromARGB(255, 172, 186, 255),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 160, 180, 255),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 183, 176, 255),
            foregroundColor: Colors.white,
          ),
        ),
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

  final List<Widget> _pages = [
    const HomePage(),
    const AdoptedDogsPage(),
    const GiveawayDogsPage(),
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
      appBar: AppBar(title: const Text('Adopt a Dog!'), centerTitle: true),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Adopted'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Giveaway'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<List<DogBreed>> futureBreeds;
  List<DogBreed> breeds = [];
  int currentIndex = 0;
  String? selectedBreed;
  String? breedImage;
  String? dogName;

  static List<Map<String, String>> adoptedDogs = [];
  static List<Map<String, String>> giveawayDogs = [];

  @override
  void initState() {
    super.initState();
    futureBreeds = fetchBreeds();
    futureBreeds.then((breedList) {
      setState(() {
        breeds = breedList;
        if (breeds.isNotEmpty) {
          _updateBreed(breeds[currentIndex].name);
        }
      });
    });
  }

  void _updateBreed(breed) async {
    final imageUrl = await fetchBreedImage(breed);
    setState(() {
      selectedBreed = breed;
      breedImage = imageUrl;
      dogName = generateWordPairs().take(1).first.asPascalCase;
    });
  }

  void _nextBreed() {
    if (breeds.isNotEmpty) {
      setState(() {
        currentIndex = (currentIndex + 1) % breeds.length;
        _updateBreed(breeds[currentIndex].name);
      });
    }
  }

  void _previousBreed() {
    if (breeds.isNotEmpty) {
      setState(() {
        currentIndex = (currentIndex - 1 + breeds.length) % breeds.length;
        _updateBreed(breeds[currentIndex].name);
      });
    }
  }

  void _adoptDog() {
    if (selectedBreed != null && breedImage != null && dogName != null) {
      // Check if the dog already exists in the adopted list
      bool alreadyAdopted = adoptedDogs.any(
        (dog) => dog["name"] == dogName! && dog["image"] == breedImage!,
      );

      if (!alreadyAdopted) {
        setState(() {
          adoptedDogs.add({
            "name": dogName!,
            "breed": selectedBreed!,
            "image": breedImage!,
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                return SizedBox(
                  width: 400, // Match image width
                  child: DropdownButton<String>(
                    isExpanded: true, // Ensures full width
                    hint: const Text('Select a breed'),
                    value: selectedBreed,
                    items:
                        breeds.map((DogBreed breed) {
                          return DropdownMenuItem<String>(
                            value: breed.name,
                            child: Text(breed.name),
                          );
                        }).toList(),
                    onChanged: (String? breed) {
                      if (breed != null) _updateBreed(breed);
                    },
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 20),
          if (dogName != null)
            SizedBox(
              width: 400, // Match image width
              child: Center(
                child: Text(
                  "Name: $dogName",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (selectedBreed != null)
            SizedBox(
              width: 400, // Match image width
              child: Center(
                child: Text(
                  "Breed: $selectedBreed",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          const SizedBox(height: 10),
          if (breedImage != null)
            Image.network(
              breedImage!,
              height: 500,
              width: 400,
              fit: BoxFit.cover,
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _previousBreed,
                child: const Text("Previous"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _adoptDog,
                child: const Text("Adopt This Dog"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _nextBreed, child: const Text("Next")),
            ],
          ),
        ],
      ),
    );
  }
}

class AdoptedDogsPage extends StatefulWidget {
  const AdoptedDogsPage({super.key});

  @override
  _AdoptedDogsPageState createState() => _AdoptedDogsPageState();
}

class _AdoptedDogsPageState extends State<AdoptedDogsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adopted Dogs")),
      body:
          HomePageState.adoptedDogs.isEmpty
              ? const Center(child: Text("No adopted dogs yet."))
              : ListView.builder(
                itemCount: HomePageState.adoptedDogs.length,
                itemBuilder: (context, index) {
                  final dog = HomePageState.adoptedDogs[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: SizedBox(
                        height: 80,
                        width: 80,
                        child: Image.network(dog["image"]!, fit: BoxFit.cover),
                      ),
                      title: Text(
                        dog["name"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        "Breed: ${dog["breed"]!}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            HomePageState.giveawayDogs.add(dog);
                            HomePageState.adoptedDogs.removeAt(index);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text("Return to Adoption"),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

class GiveawayDogsPage extends StatefulWidget {
  const GiveawayDogsPage({super.key});

  @override
  _GiveawayDogsPageState createState() => _GiveawayDogsPageState();
}

class _GiveawayDogsPageState extends State<GiveawayDogsPage> {
  void _adoptDog(int index) {
    final dog = HomePageState.giveawayDogs[index];

    // Prevent duplicate adoptions
    bool alreadyAdopted = HomePageState.adoptedDogs.any(
      (adoptedDog) =>
          adoptedDog["name"] == dog["name"] &&
          adoptedDog["image"] == dog["image"],
    );

    if (!alreadyAdopted) {
      setState(() {
        HomePageState.adoptedDogs.add(dog);
        HomePageState.giveawayDogs.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dogs for Adoption")),
      body:
          HomePageState.giveawayDogs.isEmpty
              ? const Center(child: Text("No dogs available for Adoption."))
              : ListView.builder(
                itemCount: HomePageState.giveawayDogs.length,
                itemBuilder: (context, index) {
                  final dog = HomePageState.giveawayDogs[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: Image.network(
                        dog["image"]!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        dog["name"]!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(dog["breed"]!),
                      trailing: ElevatedButton(
                        onPressed: () => _adoptDog(index),
                        child: const Text("Adopt"),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About Us")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // New welcome message
              const Text(
                "🐾 Welcome to Paws & Hearts!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Where every tail tells a story. We're dedicated to helping dogs find forever homes filled with love and care.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // New mission section
              const Text(
                "💖 Our Mission",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "At Paws & Hearts, our mission is to create lasting bonds between dogs and families. We believe every dog deserves a second chance and a home where they are cherished. Our team works hard to ensure that every adoption is a positive, seamless experience.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // New adoption process section
              const Text(
                "🚀 How It Works",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "1. **Browse** – Discover a variety of dogs waiting for a loving home.\n\n"
                "2. **Adopt** – Complete a simple application process, ensuring a perfect match.\n\n"
                "3. **Love** – Once adopted, enjoy a lifetime of joy with your new furry companion!\n\n",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // New volunteer section
              const Text(
                "🤝 Get Involved",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Looking to make a difference? Join our community of volunteers who help spread the love and care for dogs in need. Your support is crucial to making a dog's journey from shelter to home a smooth one.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Call to action
              const Center(
                child: Text(
                  "🐶 Ready to Find Your Furry Friend? Start your journey with Paws & Hearts today!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
