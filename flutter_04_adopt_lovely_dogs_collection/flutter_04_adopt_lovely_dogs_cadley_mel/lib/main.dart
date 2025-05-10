import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:english_words/english_words.dart';

void main() => runApp(const DogAdoptionApp());

class DogAdoptionApp extends StatelessWidget {
  const DogAdoptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
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
  int activeTab = 0;
  final List<Dog> myDogs = [];
  final List<Dog> donatedDogs = [];

  void switchTab(int tabIndex) {
    setState(() => activeTab = tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DogSelector(addDog: (dog) => setState(() => myDogs.add(dog))),
      MyDogs(
        dogs: myDogs,
        donateDog: (dog) => setState(() {
          myDogs.remove(dog);
          donatedDogs.add(dog);
          activeTab = 2;
        }),
      ),
      DonatedDogs(dogs: donatedDogs),
      const InfoScreen(),
    ];

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: switchTab,
        indicatorColor: Colors.teal.withOpacity(0.3),
        indicatorShape: const CircleBorder(),
        selectedIndex: activeTab,
        backgroundColor: Colors.teal.shade50,
        elevation: 8,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.house, color: Colors.teal),
            icon: Icon(Icons.house_outlined, color: Colors.tealAccent),
            label: 'Home',
            tooltip: 'Go to Home Page',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.favorite, color: Colors.teal),
            icon: Icon(Icons.favorite_border, color: Colors.tealAccent),
            label: 'Adopt',
            tooltip: 'View Adopted Dogs',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.volunteer_activism, color: Colors.teal),
            icon: Icon(Icons.volunteer_activism_outlined, color: Colors.tealAccent),
            label: 'Give Away',
            tooltip: 'See Given Away Dogs',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.pets, color: Colors.teal),
            icon: Icon(Icons.pets_outlined, color: Colors.tealAccent),
            label: 'About',
            tooltip: 'Learn About Us',
          ),
        ],
      ),
      body: screens[activeTab],
    );
  }
}

class DogSelector extends StatefulWidget {
  final void Function(Dog) addDog;

  const DogSelector({super.key, required this.addDog});

  @override
  State<DogSelector> createState() => _DogSelectorState();
}

class _DogSelectorState extends State<DogSelector> {
  late Future<List<DogBreed>> breedFetcher;
  Dog? currentDog;
  bool isDogVisible = false;
  Future<DogPicture>? dogPicFuture;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    breedFetcher = getDogBreeds();
    currentDog = Dog(
      title: '',
      type: DogBreed(title: ''),
      pic: Future.value(DogPicture(url: '')),
    );
    _searchController.addListener(() {
      setState(() => searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void pickBreed(DogBreed breed) {
    setState(() {
      dogPicFuture = getRandomDogPic(breed.title);
      currentDog = Dog(
        title: WordPair.random().join(' '),
        type: breed,
        pic: dogPicFuture!,
      );
      isDogVisible = true;
    });
  }

  void adoptCurrentDog() {
    if (currentDog!.title.isEmpty || currentDog!.type.title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a dog to adopt!')),  
      );   
         return;
    }
    widget.addDog(currentDog!);
    setState(() => isDogVisible = false);
  }

  void showNextDog() {
    setState(() {
      currentDog = Dog(
        title: '',
        type: DogBreed(title: ''),
        pic: Future.value(DogPicture(url: '')),
      );
      dogPicFuture = null;
      isDogVisible = false;
    });

    breedFetcher.then((breedList) {
      if (breedList.isNotEmpty) {
        final randomPick = breedList[Random().nextInt(breedList.length)];
        dogPicFuture = getRandomDogPic(randomPick.title);
        setState(() {
          currentDog = Dog(
            title: WordPair.random().join(' '),
            type: randomPick,
            pic: dogPicFuture!,
          );
          isDogVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade200, Colors.teal.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search breeds...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const Text(
            'Choose Your Dog Breed',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<DogBreed>>(
            future: breedFetcher,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              if (snap.hasError) return Text('Error: ${snap.error}');
              if (snap.hasData && snap.data!.isNotEmpty) {
                final breeds = snap.data!
                    .where((breed) => breed.title.toLowerCase().contains(searchQuery.toLowerCase()))
                    .toList();
                if (breeds.isEmpty) {
                  return const Text('No matching breeds found.');
                }
                return DropdownButton<DogBreed>(
                  items: breeds.map((b) => DropdownMenuItem(value: b, child: Text(b.title.toUpperCase()))).toList(),
                  onChanged: (val) => val != null ? pickBreed(val) : null,
                  hint: const Text('Select a breed'),
                );
              }
              return const Text('No breeds available.');
            },
          ),
          if (isDogVisible) ...[
            const SizedBox(height: 20),
            FutureBuilder<DogPicture>(
              future: dogPicFuture,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
                if (snap.hasError) return Text('Error: ${snap.error}');
                if (snap.hasData) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(snap.data!.url, height: 300, fit: BoxFit.cover),
                  );
                }
                return const SizedBox();
              },
            ),
            Text(currentDog!.title.toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal)),
            Text(currentDog!.type.title.toUpperCase(), style: const TextStyle(fontSize: 24, color: Colors.tealAccent)),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: adoptCurrentDog,
                style: ElevatedButton.styleFrom(
  backgroundColor: Colors.teal, // Use backgroundColor instead of primary
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
),
                child: const Text('Adopt', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: showNextDog,
               style: ElevatedButton.styleFrom(
  backgroundColor: Colors.tealAccent, // Use backgroundColor instead of primary
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
),
                child: const Text('Next Dog', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyDogs extends StatelessWidget {
  final List<Dog> dogs;
  final void Function(Dog) donateDog;

  const MyDogs({super.key, required this.dogs, required this.donateDog});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dogs.length,
      itemBuilder: (ctx, idx) {
        final dog = dogs[idx];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: ListTile(
            leading: FutureBuilder<DogPicture>(
              future: dog.pic,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
                if (snap.hasError || !snap.hasData) return const Icon(Icons.error);
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(snap.data!.url, width: 50, height: 50, fit: BoxFit.cover),
                );
              },
            ),
            title: Text(dog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(dog.type.title),
            trailing: ElevatedButton(
              onPressed: () => donateDog(dog),
             style: ElevatedButton.styleFrom(
  backgroundColor: Colors.redAccent, // Use backgroundColor instead of primary
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
),
              child: const Text('Donate'),
            ),
          ),
        );
      },
    );
  }
}

class DonatedDogs extends StatelessWidget {
  final List<Dog> dogs;

  const DonatedDogs({super.key, required this.dogs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: dogs.length,
      itemBuilder: (ctx, idx) {
        final dog = dogs[idx];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<DogPicture>(
                  future: dog.pic,
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError || !snap.hasData) {
                      return const Center(child: Icon(Icons.error, size: 50));
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        snap.data!.url,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  dog.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  dog.type.title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Welcome To \n'
          'Mr. Pogi’s Lovely Dogs 🐶❤️\n'
          'Find your perfect pup—adoption made easy!  \n'
          'Mel P. Cadley',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
      ),
    );
  }
}

class Dog {
  final String title;
  final DogBreed type;
  final Future<DogPicture> pic;

  Dog({required this.title, required this.type, required this.pic});
}

class DogBreed {
  final String title;

  DogBreed({required this.title});

  factory DogBreed.fromData(String name) => DogBreed(title: name);
}

class DogPicture {
  final String url;

  DogPicture({required this.url});

  factory DogPicture.fromData(Map<String, dynamic> data) => DogPicture(url: data['message']);
}

Future<List<DogBreed>> getDogBreeds() async {
  final resp = await http.get(Uri.parse('https://dog.ceo/api/breeds/list/all'));
  if (resp.statusCode == 200) {
    final json = jsonDecode(resp.body);
    return (json['message'] as Map<String, dynamic>).keys.map((k) => DogBreed.fromData(k)).toList();
  }
  throw Exception('Could not load breeds');
}

Future<DogPicture> getRandomDogPic(String breed) async {
  final resp = await http.get(Uri.parse('https://dog.ceo/api/breed/$breed/images/random'));
  if (resp.statusCode == 200) {
    return DogPicture.fromData(jsonDecode(resp.body));
  }
  throw Exception('Could not load dog picture');
}