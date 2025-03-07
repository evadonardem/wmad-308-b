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
      title: 'Lovely Dogs By Joward Calado',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 216, 158, 54)),
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
  final List<BreedDog> adoptedDogs = []; // Stores adopted dogs
  final List<BreedDog> returnedDogs = []; // Stores returned dogs

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _returnDog(BreedDog dog) {
    setState(() {
      adoptedDogs.remove(dog); // Remove from adopted list
      returnedDogs.add(dog); // Add to returned list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          MyHomePage(
            title: 'SMB | Lovely Dogs',
            onAdopt: (dog) {
              setState(() {
                adoptedDogs.add(dog); // Add to adopted list
              });
            },
          ),
          AdoptedDogsPage(
            adoptedDogs: adoptedDogs,
            onReturn: (dog) {
              setState(() {
                adoptedDogs.remove(dog);
                returnedDogs.add(dog); // Move to returned list
              });
            },
          ),
          ReturnedDogsPage(
            returnedDogs: returnedDogs,
            onAdopt: (dog) {
              setState(() {
                returnedDogs.remove(dog);
                adoptedDogs.add(dog); // Move back to adopted list
              });
            },
          ),
          AboutPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Adopted'),
          BottomNavigationBarItem(
              icon: Icon(Icons.heart_broken_rounded), label: 'Returned'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 216, 158, 54),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final Function(BreedDog) onAdopt; // Accept onAdopt callback

  const MyHomePage({super.key, required this.title, required this.onAdopt});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Breed>> futureBreeds;
  Future<BreedImage>? futureSelectedImageUrl;
  bool hasSelection = false;
  late BreedDog selectedBreedDog;
  List<BreedDog> adoptedDogs = [];

  @override
  void initState() {
    super.initState();
    futureBreeds = fetchBreeds();
    selectedBreedDog = BreedDog(
      name: "",
      breed: Breed(name: ""),
      image: Future.value(BreedImage(imageUrl: "")),
    );
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

  void adoptDog() {
    setState(() {
      widget.onAdopt(selectedBreedDog); // Send adopted dog to MainScreen
      handleBreedSelection(selectedBreedDog.breed); // Load new dog
    });
  }

  void showNextDog() {
    handleBreedSelection(selectedBreedDog.breed);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
                      value: selectedBreedDog.breed.name.isNotEmpty
                          ? selectedBreedDog.breed
                          : null,
                      hint: const Text("Select a Breed"),
                      items: breeds.map((breed) {
                        return DropdownMenuItem(
                          value: breed,
                          child: Text(
                            breed.name.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
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
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
            // Buttons only visible when a breed is selected
            Visibility(
              visible: hasSelection,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: adoptDog,
                    child: const Text("Adopt"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: showNextDog,
                    child: const Text("Show Next"),
                  ),
                ],
              ),
            ),
            // Display selected dog's name and breed only when a breed is selected
            if (hasSelection) ...[
              Text(
                selectedBreedDog.name.toUpperCase(),
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(
                selectedBreedDog.breed.name.toUpperCase(),
                style: TextStyle(fontSize: 24),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Adopted Dogs Page
class AdoptedDogsPage extends StatelessWidget {
  final List<BreedDog> adoptedDogs;
  final Function(BreedDog) onReturn;

  const AdoptedDogsPage(
      {super.key, required this.adoptedDogs, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adopted Dogs')),
      body: adoptedDogs.isEmpty
          ? const Center(child: Text('No adopted dogs yet.'))
          : ListView.builder(
              itemCount: adoptedDogs.length,
              itemBuilder: (context, index) {
                final dog = adoptedDogs[index];
                return Card(
                  child: ListTile(
                    title: Text(dog.name),
                    subtitle: Text(dog.breed.name),
                    leading: FutureBuilder<BreedImage>(
                      future: dog.image,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Icon(Icons.error);
                        } else if (snapshot.hasData) {
                          return SizedBox(
                            width: 50, // Fixed width
                            height: 50, // Fixed height
                            child: Image.network(
                              snapshot.data!.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.undo,
                          color: Colors.red), // Undo icon for returning dogs
                      onPressed: () {
                        onReturn(dog); // Move dog to returned list
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// Not Adopted Dogs Page
class ReturnedDogsPage extends StatelessWidget {
  final List<BreedDog> returnedDogs;
  final Function(BreedDog) onAdopt;

  const ReturnedDogsPage(
      {super.key, required this.returnedDogs, required this.onAdopt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Returned Dogs')),
      body: returnedDogs.isEmpty
          ? const Center(child: Text('No returned dogs yet.'))
          : ListView.builder(
              itemCount: returnedDogs.length,
              itemBuilder: (context, index) {
                final dog = returnedDogs[index];
                return Card(
                  child: ListTile(
                    title: Text(dog.name),
                    subtitle: Text(dog.breed.name),
                    leading: FutureBuilder<BreedImage>(
                      future: dog.image,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Icon(Icons.error);
                        } else if (snapshot.hasData) {
                          return SizedBox(
                            width: 50, // Fixed width
                            height: 50, // Fixed height
                            child: Image.network(
                              snapshot.data!.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.pets,
                          color: Colors.green), // Green check icon for adopting
                      onPressed: () {
                        onAdopt(dog); // Move dog back to adopted list
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// About Page
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08, vertical: screenHeight * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Cute Dog Illustration
              Image.asset(
                '../assets/images/dog_illustration.png', // Add an illustration here
                width: screenWidth * 0.2,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                '🐶 Lovely Dogs Adoption App',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 216, 158, 54)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              // Description
              const Text(
                'Lovely Dogs is a pet adoption app designed to help you find your perfect furry friend. '
                'Browse through different breeds, see adorable pictures, and give a loving home to a dog in need. '
                'Start your journey of companionship today! 🐾',
                style:
                    TextStyle(fontSize: 18, height: 1.5, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              // "Adopt Now" Button
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to the Home tab if using bottom navigation
                  final mainScreenState =
                      context.findAncestorStateOfType<_MainScreenState>();
                  if (mainScreenState != null) {
                    mainScreenState._onItemTapped(0);
                  }
                },
                icon: const Icon(Icons.pets, size: 24, color: Colors.white),
                label: const Text(
                  'Adopt Now!',
                  style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(221, 255, 255, 255),
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  backgroundColor: const Color.fromARGB(255, 216, 158, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      ),
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
  final response =
      await http.get(Uri.parse('https://dog.ceo/api/breeds/list/all'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List.from(data['message'].keys.map((name) => Breed.fromJson(name)));
  } else {
    throw Exception('Failed to fetch breeds');
  }
}

Future<BreedImage> fetchRandomAnimalFromBreed(String breed) async {
  final response = await http
      .get(Uri.parse('https://dog.ceo/api/breed/$breed/images/random'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return BreedImage.fromJson(data);
  } else {
    throw Exception('Failed to fetch image from breed');
  }
}