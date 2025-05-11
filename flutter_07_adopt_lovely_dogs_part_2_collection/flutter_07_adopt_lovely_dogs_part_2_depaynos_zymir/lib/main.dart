import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:english_words/english_words.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/intl.dart';
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
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
  final bool _isLoading = true;
  final bool _isEditing = false;
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
        indicatorColor: Colors.deepPurple.withOpacity(0.2),
        backgroundColor: Colors.deepPurple[50],
        selectedIndex: currentPageIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: Colors.deepPurple),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.pets, color: Colors.deepPurple),
            icon: Icon(Icons.pets_outlined),
            label: 'Adopt',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.handshake, color: Colors.deepPurple),
            icon: Icon(Icons.handshake_outlined),
            label: 'Given Away',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.info, color: Colors.deepPurple),
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
        ],
      ),
      body: <Widget>[
        HomePage(onAdopted: (dog) async {
          final Map<String, dynamic> dogMap = await dog.toMap();
          await _dbHelper.insertDog(dogMap);
          setState(() {
            adoptedDogs.add(dog);
          });
        }),
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
        const AboutPage(),
      ][currentPageIndex],
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.deepPurple,
                child: Icon(
                  Icons.pets,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hello!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'My name is Jehaiah Ambas',
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'This is a dog adoption app created with Flutter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.email),
                label: const Text('Contact Me'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessagesPage extends StatelessWidget {
  final List<BreedDog> givenAwayDogs;

  const MessagesPage({super.key, required this.givenAwayDogs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dogs Given Away'),
        backgroundColor: Colors.deepPurple[50],
      ),
      body: givenAwayDogs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.heart_broken,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No dogs given away yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: givenAwayDogs.length,
              itemBuilder: (context, index) {
                final dog = givenAwayDogs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: FutureBuilder<BreedImage>(
                              future: dog.image,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return const Center(child: Icon(Icons.error));
                                } else if (snapshot.hasData) {
                                  return Image.network(
                                    snapshot.data!.imageUrl,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return const Center(child: Icon(Icons.error));
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dog.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                dog.breed.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Given on ${DateFormat('MMM d, y').format(dog.adoptedDate)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[400],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(BreedDog) onAdopted;

  const HomePage({super.key, required this.onAdopted});

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
        image: Future.value(BreedImage(imageUrl: "")));
  }

  void handleBreedSelection(Breed breed) {
    setState(() {
      final wordPair = WordPair.random().join(" ");
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
        const SnackBar(content: Text("No image or breed selected for adoption!")),
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
            name: WordPair.random().join(" "),
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Find Your Perfect Companion",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "Select a Dog Breed",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<List<Breed>>(
                        future: futureBreeds,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            var breeds = snapshot.data!;
                            return DropdownMenu(
                              width: MediaQuery.of(context).size.width - 100,
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
                    ],
                  ),
                ),
              ),

              if (hasSelection) ...[
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        FutureBuilder<BreedImage>(
                          future: futureSelectedImageUrl,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('${snapshot.error}');
                            } else if (snapshot.hasData) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  snapshot.data!.imageUrl,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          selectedBreedDog.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Text(
                          selectedBreedDog.breed.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: handleAdopt,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              ),
                              child: const Text(
                                "Adopt",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 20),
                            OutlinedButton(
                              onPressed: handleNext,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.deepPurple),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              ),
                              child: const Text(
                                "Next",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.deepPurple),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AdoptPage extends StatefulWidget {
  final List<BreedDog> adoptedDogs;
  final Function(BreedDog) onGiveAway;

  const AdoptPage(
      {super.key, required this.adoptedDogs, required this.onGiveAway});

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

  void _handleDelete(BreedDog dog) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleGiveAway(BreedDog dog) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            child:
                const Text('Give Away', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.deepPurple),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Adopted Dogs'),
        backgroundColor: Colors.deepPurple[50],
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
            tooltip: 'Add New Dog',
          ),
        ],
      ),
      body: _adoptedDogs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No dogs adopted yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _showAddDialog,
                    child: const Text('Add your first dog'),
                  ),
                ],
              ),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8,
              ),
              padding: const EdgeInsets.all(16.0),
              itemCount: _adoptedDogs.length,
              itemBuilder: (context, index) {
                final dog = _adoptedDogs[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _isEditing = true;
                        _editingDog = dog;
                        _nameController.text = dog.name;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: FutureBuilder<BreedImage>(
                              future: dog.image,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return const Center(
                                      child: Icon(Icons.error));
                                } else if (snapshot.hasData) {
                                  return Image.network(
                                    snapshot.data!.imageUrl,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return const Center(child: Icon(Icons.error));
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      dog.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18),
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
                              Text(
                                dog.breed.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red[400],
                                    onPressed: () => _handleDelete(dog),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.handshake),
                                    color: Colors.green[400],
                                    onPressed: () => _handleGiveAway(dog),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
    final imageUrl = (await image).imageUrl;
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
        data['message'].keys.map((name) => Breed.fromJson(name)));
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