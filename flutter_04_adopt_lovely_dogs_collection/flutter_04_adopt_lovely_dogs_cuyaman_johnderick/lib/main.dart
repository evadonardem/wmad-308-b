import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:english_words/english_words.dart';
import 'dart:math';

void main() => runApp(const NavigationBarApp());

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
          NavigationDestination(
            icon: Icon(Icons.pets),
            label: 'Adopt',
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake),
            label: 'Give Away',
          ),
          NavigationDestination(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
      body: <Widget>[
        HomePage(onAdopted: (dog) {
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
          'Adopt a Lovely Dog by Cuyam-an, John Derick',
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
                    dropdownMenuEntries: breeds
                        .map((breed) => DropdownMenuEntry(
                            value: breed, label: breed.name.toUpperCase()))
                        .toList(),
                    onSelected: (value) {
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
              ElevatedButton(
                onPressed: handleNext, 
                child: const Text("Next"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdoptPage extends StatelessWidget {
  final List<BreedDog> adoptedDogs;
  final Function(BreedDog) onGiveAway;

  const AdoptPage({Key? key, required this.adoptedDogs, required this.onGiveAway}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: adoptedDogs.length,
      itemBuilder: (BuildContext context, int index) {
        final dog = adoptedDogs[index];
        return ListTile(
          leading: FutureBuilder<BreedImage>( 
            future: dog.image,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Icon(Icons.error);
              } else if (snapshot.hasData) {
                return Image.network(snapshot.data!.imageUrl, width: 50, height: 50, fit: BoxFit.cover);
              }
              return const Icon(Icons.error);
            },
          ),
          title: Text(dog.name),
          subtitle: Text(dog.breed.name),
          trailing: ElevatedButton(
            onPressed: () => onGiveAway(dog),
            child: const Text("Give Away"),
          ),
        );
      },
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
  final dogBreedsEndpoint = 'https://dog.ceo/api/breeds/list/all';
  final response = await http.get(Uri.parse(dogBreedsEndpoint));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<Breed> breeds = List.from(data['message'].keys.map((name) => Breed.fromJson(name)));
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