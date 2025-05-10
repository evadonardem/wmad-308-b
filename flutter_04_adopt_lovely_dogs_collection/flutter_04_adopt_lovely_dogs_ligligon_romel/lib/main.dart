import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:english_words/english_words.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const MyHomePage(),
    AdoptedDogsPage(),
    GaveAwayDogsPage(),
    const AboutPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lovely Dogs',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color.fromARGB(255, 241, 224, 147),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Adopted'),
            BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Gave Away'),
            BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(255, 73, 182, 173),
          unselectedItemColor: const Color.fromARGB(255, 88, 69, 69),
          backgroundColor: const Color.fromARGB(255, 69, 121, 180),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About"), backgroundColor: Colors.pinkAccent),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Lovely Dogs App\nFind and adopt friendly and lovely dogs!\n\ngive them the love that they need. \n by Ligligon Romel",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class GaveAwayDogsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gave Away Dogs"), backgroundColor: Colors.pinkAccent),
      body: gaveAwayDogs.isEmpty
          ? const Center(child: Text("No dogs given away yet!", style: TextStyle(fontSize: 18)))
          : ListView.builder(
              itemCount: gaveAwayDogs.length,
              itemBuilder: (context, index) {
                final dog = gaveAwayDogs[index];
                return Center(
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Container(
                      width: 300, // Fixed width for a compact look
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(dog.imageUrl, height: 180, width: 250, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 10),
                          Text(dog.name.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("Breed: ${dog.breed.toUpperCase()}", style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class AdoptedDogsPage extends StatefulWidget {
  @override
  _AdoptedDogsPageState createState() => _AdoptedDogsPageState();
}

class _AdoptedDogsPageState extends State<AdoptedDogsPage> {
  void giveAwayDog(Dogjhez dog) {
    setState(() {
      adoptedDogs.remove(dog);
      gaveAwayDogs.add(dog);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adopted Dogs"), backgroundColor: Colors.pinkAccent),
      body: adoptedDogs.isEmpty
          ? const Center(child: Text("No adopted dogs yet!", style: TextStyle(fontSize: 18)))
          : ListView.builder(
              itemCount: adoptedDogs.length,
              itemBuilder: (context, index) {
                final dog = adoptedDogs[index];
                return Center(
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Container(
                      width: 300, // Fixed width for a compact look
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(dog.imageUrl, height: 180, width: 250, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 10),
                          Text(dog.name.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("Breed: ${dog.breed.toUpperCase()}", style: const TextStyle(color: Colors.black54)),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => giveAwayDog(dog),
                            child: const Text("Give Away"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.pink,
                              side: const BorderSide(color: Colors.pink, width: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adopted Dogs"), backgroundColor: Colors.pinkAccent),
      body: adoptedDogs.isEmpty
          ? const Center(child: Text("No adopted dogs yet!", style: TextStyle(fontSize: 18)))
          : ListView.builder(
              itemCount: adoptedDogs.length,
              itemBuilder: (context, index) {
                final dog = adoptedDogs[index];
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(dog.imageUrl)),
                  title: Text(dog.name),
                  subtitle: Text(dog.breed.toUpperCase()),
                );
              },
            ),
    );
  }


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<String>> futureBreeds;
  List<String> breedsList = [];
  Future<Dogjhez>? futureSelectedDog;
  bool hasSelection = false;
  bool isAdopted = false;
  String currentBreed = "";

  @override
  void initState() {
    super.initState();
    futureBreeds = fetchBreeds().then((breeds) {
      setState(() {
        breedsList = breeds;
      });
      return breeds;
    });
  }

  void handleBreedSelection(String breed) {
    setState(() {
      currentBreed = breed;
      hasSelection = true;
      isAdopted = false;
      futureSelectedDog = fetchRandomDogFromBreed(breed);
    });
  }

  void showNextBreed() {
    if (breedsList.isEmpty) return;

    setState(() {
      final currentIndex = breedsList.indexOf(currentBreed);
      final nextIndex = (currentIndex + 1) % breedsList.length;
      currentBreed = breedsList[nextIndex];
      futureSelectedDog = fetchRandomDogFromBreed(currentBreed);
      isAdopted = false;
    });
  }

  void adoptDog(Dogjhez dog) {
    setState(() {
      if (!adoptedDogs.contains(dog)) {
        adoptedDogs.add(dog);
      }
      isAdopted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lovely Dogs'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              const Text(
                "Find Your Lovely Dog!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink),
              ),
              const SizedBox(height: 4),
              const Text(
                "Choose a breed and find your perfect companion!",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<String>>(
                future: futureBreeds,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return DropdownButton<String>(
                      value: currentBreed.isNotEmpty ? currentBreed : null,
                      hint: const Text("Select Breed"),
                      onChanged: (value) {
                        if (value != null) handleBreedSelection(value);
                      },
                      items: snapshot.data!
                          .map((breed) => DropdownMenuItem(
                              value: breed, child: Text(breed.toUpperCase())))
                          .toList(),
                    );
                  }
                  return const Text("No breeds found.");
                },
              ),
              if (hasSelection && futureSelectedDog != null)
                FutureBuilder<Dogjhez>(
                  future: futureSelectedDog,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    } else if (snapshot.hasData) {
                      return Column(
                        children: [
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.pink, width: 2),
                              image: DecorationImage(
                                image: NetworkImage(snapshot.data!.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.data!.name.toUpperCase(),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: isAdopted ? null : () => adoptDog(snapshot.data!),
                                icon: const Icon(Icons.favorite),
                                label: Text(isAdopted ? "Adopted" : "Adopt"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAdopted ? Colors.pink : Colors.white,
                                  foregroundColor: isAdopted ? Colors.white : Colors.pink,
                                  side: const BorderSide(color: Colors.pink, width: 2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () => showNextBreed(),
                                icon: const Icon(Icons.navigate_next),
                                label: const Text("Next Breed"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.pink,
                                  side: const BorderSide(color: Colors.pink, width: 2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Dogjhez {
  final String breed;
  final String imageUrl;
  final String name;

  Dogjhez({required this.breed, required this.imageUrl, required this.name});
}

List<Dogjhez> adoptedDogs = [];
List<Dogjhez> gaveAwayDogs = [];

Future<List<String>> fetchBreeds() async {
  final response = await http.get(Uri.parse('https://dog.ceo/api/breeds/list/all'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return (data['message'] as Map<String, dynamic>).keys.toList();
  } else {
    throw Exception('Failed to load breeds');
  }
}

Future<Dogjhez> fetchRandomDogFromBreed(String breed) async {
  final response = await http.get(Uri.parse('https://dog.ceo/api/breed/$breed/images/random'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return Dogjhez(breed: breed, imageUrl: data['message'], name: generateRandomName());
  } else {
    throw Exception('Failed to load dog image');
  }
}

String generateRandomName() {
  return WordPair.random().asPascalCase;
}