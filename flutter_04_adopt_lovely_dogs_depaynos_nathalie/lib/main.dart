import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const NavigatorBar(title:'namemem'),
    );
  }
}

class NavigatorBar extends StatefulWidget {
  const NavigatorBar({super.key, required String title});

  @override
  State<NavigatorBar> createState() => _HomePage();
}

class _HomePage extends State<NavigatorBar> {
  int currentPageIndex = 0;
  List<BreedDog> adoptedDogs = [];
  List<BreedDog> givenAwayDogs = [];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
            icon: Icon(Icons.recycling),
            label: 'Give Away',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
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

        AdoptPage(adoptedDogs: adoptedDogs, onGiveAway: (dog) {
          setState(() {
            adoptedDogs.remove(dog);
            givenAwayDogs.add(dog);
          });
        }),

        GiveAwayPage(givenAwayDogs: givenAwayDogs),

        AboutPage(),
      ][currentPageIndex],
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
      final wordPair = WordPair.random().join("").toUpperCase();
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
          name: WordPair.random().join("").toUpperCase(), 
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
              future:
                  futureSelectedImageUrl, 
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
                      width: 300,
                      fit: BoxFit.cover,
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
            style: TextStyle(fontSize: 15),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: handleAdopt,
                child: const Text("Adopt"),
              ),
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

//page class
class AdoptPage extends StatelessWidget {
  final List<BreedDog> adoptedDogs;
  final Function(BreedDog) onGiveAway;

  const AdoptPage({Key? key, required this.adoptedDogs, required this.onGiveAway}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: adoptedDogs.length,
        itemBuilder: (BuildContext context, int index) {
          final dog = adoptedDogs[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<BreedImage>(
                  future: dog.image,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.error);
                    } else if (snapshot.hasData) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          snapshot.data!.imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                    return const Icon(Icons.error);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(dog.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(dog.breed.name.toUpperCase(), style: const TextStyle(color: Colors.grey)),
                      ElevatedButton(
                        onPressed: () => onGiveAway(dog),
                        child: const Text("Give Away"),
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
}

class GiveAwayPage extends StatelessWidget {
  final List<BreedDog> givenAwayDogs;

  const GiveAwayPage({Key? key, required this.givenAwayDogs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: givenAwayDogs.length,
        itemBuilder: (BuildContext context, int index) {
          final dog = givenAwayDogs[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<BreedImage>(
                  future: dog.image,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.error);
                    } else if (snapshot.hasData) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          snapshot.data!.imageUrl,
                          width: double.infinity,
                          height: 200, 
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                    return const Icon(Icons.error);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(dog.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(dog.breed.name.toUpperCase(), style: const TextStyle(color: Colors.grey)),
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
}


class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Made by:", style: TextStyle(),),
              Text("Nathalie Franchet H. Depaynos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
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
  final dogBreedsEndpoint = 'https://dog.ceo/api/breeds/list/all';
  final response = await http.get(Uri.parse(dogBreedsEndpoint));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<Breed> breeds =
        List.from(data['message'].keys.map((name) => Breed.fromJson(name)));
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