import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:english_words/english_words.dart';
import 'dart:math';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database/database_helper.dart';
import 'database/database_init.dart';

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();
  runApp(const NavigationBarApp());
}

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;
  List<BreedDog> adoptedDogs = [];
  List<BreedDog> givenAwayDogs = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = true;
  bool _isEditing = false;
  BreedDog? _editingDog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: const Color.fromARGB(59, 166, 20, 224),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.pets), label: 'Adopt'),
          NavigationDestination(
            icon: Icon(Icons.handshake),
            label: 'Give Away',
          ),
          NavigationDestination(icon: Icon(Icons.info), label: 'About'),
        ],
      ),
      body:
          <Widget>[
            HomePage(
              onAdopted: (dog) async {
                final Map<String, dynamic> dogMap = await dog.toMap();
                await _dbHelper.insertDog(dogMap);
                setState(() {
                  adoptedDogs.add(dog);
                });
              },
            ),

            AdoptPage(
              adoptedDogs: adoptedDogs,
              onGiveAway: (dog) {
                setState(() {
                  adoptedDogs.remove(dog);
                  givenAwayDogs.add(dog);
                  currentPageIndex = 2;
                });
              },
            ),

            MessagesPage(givenAwayDogs: givenAwayDogs),

            AboutPage(),
          ][currentPageIndex],
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Hello! My name is Nathalie Depaynos.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class MessagesPage extends StatelessWidget {
  final List<BreedDog> givenAwayDogs;

  const MessagesPage({Key? key, required this.givenAwayDogs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: givenAwayDogs.length,
      itemBuilder: (context, index) {
        final dog = givenAwayDogs[index];
        return ListTile(
          leading: FutureBuilder<BreedImage>(
            future: dog.image,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Icon(Icons.error);
              } else if (snapshot.hasData) {
                return Image.network(
                  snapshot.data!.imageUrl,
                  width: 200,
                  height: 100,
                  fit: BoxFit.cover,
                );
              }
              return const SizedBox();
            },
          ),
          title: Text(dog.name),
          subtitle: Text(dog.breed.name),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(BreedDog) onAdopted;

  const HomePage({Key? key, required this.onAdopted}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Breed>> futureBreeds;
  late BreedDog selectedBreedDog;
  bool hasSelection = false;
  Future<BreedImage>? futureSelectedImageUrl;

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

  void handleAdopt() {
    if (selectedBreedDog.name.isEmpty || selectedBreedDog.breed.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No image or breed selected for adoption!"),
        ),
      );
      return;
    }

    widget.onAdopted(selectedBreedDog);
    setState(() {
      hasSelection = false;
    });
  }

  void handleNext() {
    setState(() {
      selectedBreedDog = BreedDog(
        name: "",
        breed: Breed(name: ""),
        image: Future.value(BreedImage(imageUrl: "")),
      );
      futureSelectedImageUrl = null;
      hasSelection = false;
    });

    futureBreeds.then((breeds) {
      final breedList = breeds ?? [];
      if (breedList.isNotEmpty) {
        final randomBreed = breedList[Random().nextInt(breedList.length)];

        futureSelectedImageUrl = fetchRandomAnimalFromBreed(randomBreed.name);

        setState(() {
          selectedBreedDog = BreedDog(
            name: WordPair.random().join(""),
            breed: randomBreed,
            image: futureSelectedImageUrl!,
          );
          hasSelection = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                return DropdownMenu(
                  dropdownMenuEntries:
                      breeds
                          .map(
                            (breed) => DropdownMenuEntry(
                              value: breed,
                              label: breed.name.toUpperCase(),
                            ),
                          )
                          .toList(),
                  onSelected: (value) {
                    if (value != null) handleBreedSelection(value);
                  },
                );
              }
              return const Text("No breeds found.");
            },
          ),
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
                    child: Image.network(snapshot.data!.imageUrl, height: 300),
                  );
                }
                return const SizedBox();
              },
            ),

          Text(
            selectedBreedDog.name.toUpperCase(),
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Text(
            selectedBreedDog.breed.name.toUpperCase(),
            style: TextStyle(fontSize: 24),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: handleAdopt,
                child: const Text("Adopt"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: handleNext, child: const Text("Next")),
            ],
          ),
        ],
      ),
    );
  }
}

class AdoptPage extends StatefulWidget {
  final List<BreedDog> adoptedDogs;
  final Function(BreedDog) onGiveAway;

  const AdoptPage({
    Key? key,
    required this.adoptedDogs,
    required this.onGiveAway,
  }) : super(key: key);

  @override
  _AdoptPageState createState() => _AdoptPageState();
}

class _AdoptPageState extends State<AdoptPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<BreedDog> _adoptedDogs = [];
  bool _isLoading = true;
  bool _isEditing = false;
  BreedDog? _editingDog;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDogs();
  }

  Future<void> _loadDogs() async {
    setState(() => _isLoading = true);
    try {
      final List<Map<String, dynamic>> dogs = await _dbHelper.queryAllDogs();
      if (mounted) {
        setState(() {
          _adoptedDogs = dogs.map((dog) => BreedDog.fromMap(dog)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dogs: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _addDog(BreedDog dog) async {
    try {
      final Map<String, dynamic> dogMap = await dog.toMap();
      await _dbHelper.insertDog(dogMap);
      await _loadDogs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding dog: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _updateDog(BreedDog dog) async {
    try {
      final Map<String, dynamic> dogMap = await dog.toMap();
      await _dbHelper.updateDog(dogMap);
      await _loadDogs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating dog: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteDog(int id) async {
    try {
      await _dbHelper.deleteDog(id);
      await _loadDogs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting dog: ${e.toString()}')),
        );
      }
    }
  }

  // 1. Implement _handleEditComplete
  void _handleEditComplete() {
    if (_nameController.text.trim().isNotEmpty && _editingDog != null) {
      final updatedDog = BreedDog(
        id: _editingDog!.id,
        name: _nameController.text.trim(),
        breed: _editingDog!.breed,
        image: _editingDog!.image,
        adoptedDate: _editingDog!.adoptedDate,
      );
      _updateDog(updatedDog);
      if (mounted) {
        setState(() {
          _isEditing = false;
          _editingDog = null;
          _nameController.clear();
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid name')),
      );
    }
  }

  // 2. Implement _handleDelete
  void _handleDelete(BreedDog dog) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this dog?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (dog.id != null) {
                    await _deleteDog(dog.id!);
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // 3. Implement _handleGiveAway
  void _handleGiveAway(BreedDog dog) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Give Away'),
            content: const Text('Are you sure you want to give away this dog?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (dog.id != null) {
                    await _deleteDog(dog.id!);
                    if (mounted) {
                      widget.onGiveAway(dog);
                    }
                  }
                },
                child: const Text(
                  'Give Away',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Dog'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter dog name',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a name')),
                    );
                    return;
                  }

                  final newDog = BreedDog(
                    name: name,
                    breed: Breed(name: 'Unknown'),
                    image: fetchRandomAnimalFromBreed('Unknown'),
                  );

                  await _addDog(newDog);
                  if (mounted) {
                    _nameController.clear();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title:
            _isEditing
                ? TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter new name',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                )
                : const Text(''),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _handleEditComplete,
            ),
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.add),
            onPressed: () {
              if (_isEditing) {
                setState(() {
                  _isEditing = false;
                  _editingDog = null;
                  _nameController.clear();
                });
              } else {
                _showAddDialog();
              }
            },
          ),
        ],
      ),
      body:
          _adoptedDogs.isEmpty
              ? const Center(
                child: Text(
                  'No dogs adopted yet!',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.75,
                ),
                padding: const EdgeInsets.all(16.0),
                itemCount: _adoptedDogs.length,
                itemBuilder: (context, index) {
                  final dog = _adoptedDogs[index];
                  return Card(
                    elevation: 4.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FutureBuilder<BreedImage>(
                            future: dog.image,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return const Center(child: Icon(Icons.error));
                              } else if (snapshot.hasData) {
                                return Image.network(
                                  snapshot.data!.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                );
                              }
                              return const Center(child: Icon(Icons.error));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onDoubleTap: () {
                                  setState(() {
                                    _isEditing = true;
                                    _editingDog = dog;
                                    _nameController.text = dog.name;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        dog.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        setState(() {
                                          _isEditing = true;
                                          _editingDog = dog;
                                          _nameController.text = dog.name;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                dog.breed.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _handleDelete(dog),
                                    child: const Text('Delete'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => _handleGiveAway(dog),
                                    child: const Text('Give Away'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

class BreedDog {
  int? id;
  String name;
  final Breed breed;
  final Future<BreedImage> image;
  DateTime adoptedDate;

  BreedDog({
    this.id,
    required this.name,
    required this.breed,
    required this.image,
    DateTime? adoptedDate,
  }) : adoptedDate = adoptedDate ?? DateTime.now();

  Future<Map<String, dynamic>> toMap() async {
    final imageUrl = await (await image).imageUrl;
    return {
      'id': id,
      'name': name,
      'breed': breed.name,
      'imageUrl': imageUrl,
      'adoptedDate': adoptedDate.toIso8601String(),
    };
  }

  factory BreedDog.fromMap(Map<String, dynamic> map) {
    return BreedDog(
      id: map['id'],
      name: map['name'],
      breed: Breed(name: map['breed']),
      image: Future.value(BreedImage(imageUrl: map['imageUrl'])),
      adoptedDate: DateTime.parse(map['adoptedDate']),
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
    List<Breed> breeds = List.from(
      data['message'].keys.map((name) => Breed.fromJson(name)),
    );
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
