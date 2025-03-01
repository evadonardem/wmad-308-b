import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:english_words/english_words.dart';


void main() {
  runApp(const MyApp());
}


Future<List<String>> fetchDogBreeds() async {
  final response = await http.get(
    Uri.parse('https://dog.ceo/api/breeds/list/all'),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<String>.from(data['message'].keys);
  } else {
    throw Exception('Failed to load breeds');
  }
}


Future<String> fetchDogImage(String breed) async {
  final response = await http.get(
    Uri.parse('https://dog.ceo/api/breed/$breed/images/random'),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['message'];
  } else {
    throw Exception('Failed to load image');
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dog Adoption App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.deepPurpleAccent,
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 40, 32, 156),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 40, 15, 151),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 12, 37, 161),
          selectedItemColor: Color.fromARGB(255, 78, 9, 197),
          unselectedItemColor: Colors.white,
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
  List<Map<String, String>> adoptedDogs = [];
  List<Map<String, String>> giveAwayDogs = [];
  late final List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pages = [
      MyHomePage(adoptedDogs: adoptedDogs),
      AdoptedPage(adoptedDogs: adoptedDogs, giveAwayDogs: giveAwayDogs),
      GiveAwayPage(giveAwayDogs: giveAwayDogs),
      const AboutPage(),
    ];
  }


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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Adopted'),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Give Away',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  final List<Map<String, String>> adoptedDogs;


  const MyHomePage({super.key, required this.adoptedDogs});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  late Future<List<String>> futureDogBreeds;
  String? selectedBreed;
  String? dogImageUrl;
  String dogName = WordPair.random().asPascalCase;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    futureDogBreeds = fetchDogBreeds();
  }


  void updateDogImage(String breed) async {
    setState(() {
      isLoading = true;
      dogImageUrl = null;
    });


    try {
      final imageUrl = await fetchDogImage(breed);
      setState(() {
        dogImageUrl = imageUrl;
        dogName = WordPair.random().asPascalCase;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }


  void adoptDog() {
    if (selectedBreed != null && dogImageUrl != null) {
      setState(() {
        widget.adoptedDogs.add({
          "name": dogName,
          "breed": selectedBreed!,
          "image": dogImageUrl!,
        });
      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dog added to adopted list!')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          FutureBuilder<List<String>>(
            future: futureDogBreeds,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No breeds found');
              }
              return DropdownButtonFormField<String>(
                value: selectedBreed,
                hint: const Text('🐕 Select a Breed'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
                items:
                    snapshot.data!.map((breed) {
                      return DropdownMenuItem(value: breed, child: Text(breed));
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedBreed = newValue;
                  });
                  if (newValue != null) {
                    updateDogImage(newValue);
                  }
                },
              );
            },
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const CircularProgressIndicator()
          else if (dogImageUrl != null)
            Column(
              children: [
                Image.network(
                  dogImageUrl!,
                  width: 350,
                  height: 350,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                Text(
                  "🐾 Name: $dogName",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: adoptDog,
                      child: const Text("Adopt 🐶"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedBreed != null) {
                          updateDogImage(selectedBreed!);
                        }
                      },
                      child: const Text("Explore More 🔄"),
                    ),
                  ],
                ),
              ],
            )
          else
            const Text(
              "🐾 Select a breed to see its image",
              style: TextStyle(color: Colors.white),
            ),
        ],
      ),
    );
  }
}


class AdoptedPage extends StatefulWidget {
  final List<Map<String, String>> adoptedDogs;
  final List<Map<String, String>> giveAwayDogs;


  const AdoptedPage({
    super.key,
    required this.adoptedDogs,
    required this.giveAwayDogs,
  });


  @override
  State<AdoptedPage> createState() => _AdoptedPageState();
}


class _AdoptedPageState extends State<AdoptedPage> {
  void letGoDog(int index) {
    setState(() {
      widget.giveAwayDogs.add(widget.adoptedDogs[index]);
      widget.adoptedDogs.removeAt(index);
    });


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dog moved to Give Away')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adopted Dogs')),
      body:
          widget.adoptedDogs.isEmpty
              ? const Center(child: Text('No adopted dogs yet!'))
              : ListView.builder(
                itemCount: widget.adoptedDogs.length,
                itemBuilder: (context, index) {
                  final dog = widget.adoptedDogs[index];
                  return ListTile(
                    leading: Image.network(
                      dog["image"]!,
                      width: 50,
                      height: 50,
                    ),
                    title: Text(
                      dog["name"]!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Breed: ${dog["breed"]}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: TextButton(
                      onPressed: () => letGoDog(index),
                      child: const Text(
                        "Give Away",
                        style: TextStyle(color: Color.fromARGB(255, 9, 184, 102)),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}


class GiveAwayPage extends StatefulWidget {
  final List<Map<String, String>> giveAwayDogs;


  const GiveAwayPage({super.key, required this.giveAwayDogs});


  @override
  State<GiveAwayPage> createState() => _GiveAwayPageState();
}


class _GiveAwayPageState extends State<GiveAwayPage> {
  void deleteDog(int index) {
    setState(() {
      widget.giveAwayDogs.removeAt(index);
    });


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dog removed from Give Away')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Give Away Dogs')),
      body:
          widget.giveAwayDogs.isEmpty
              ? const Center(child: Text('No dogs available for adoption'))
              : ListView.builder(
                itemCount: widget.giveAwayDogs.length,
                itemBuilder: (context, index) {
                  final dog = widget.giveAwayDogs[index];
                  return ListTile(
                    leading: Image.network(
                      dog["image"]!,
                      width: 50,
                      height: 50,
                    ),
                    title: Text(
                      dog["name"]!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Breed: ${dog["breed"]}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteDog(index),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Info 1',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'No info',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          const Text(
            'Info 2',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'No info',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          const Text(
            'Info 3:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'No info',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}