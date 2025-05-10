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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(150, 255, 115, 0),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Lovely Dogs By Anablon Jhemar'),
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
  Breed? selectedBreed;
  int _selectedIndex = 0;
  List<BreedDog> adoptedDogs = [];
  List<BreedDog> giveAwayDogs = [];

  @override
  void initState() {
    super.initState();
    futureBreeds = fetchBreeds();
  }

  void handleBreedSelection(Breed breed) {
    setState(() {
      futureSelectedImageUrl = fetchRandomAnimalFromBreed(breed.name);
      hasSelection = true;
      selectedBreed = breed;
    });
  }

  void adoptDog() {
    if (selectedBreed != null && futureSelectedImageUrl != null) {
      futureSelectedImageUrl!.then((image) {
        setState(() {
          adoptedDogs.add(BreedDog(name: selectedBreed!.name, breed: selectedBreed!, image: image.imageUrl));
        });
      });
    }
  }

  void showNextBreed() {
  if (selectedBreed != null) {
    setState(() {
      futureBreeds.then((breeds) {
        final random = breeds..shuffle();
        selectedBreed = random.first;
        futureSelectedImageUrl = fetchRandomAnimalFromBreed(selectedBreed!.name);
      });
    });
  }
}

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 80,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 0))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, color: Colors.white, size: 40),
                SizedBox(height: 20),
                _buildNavItem(Icons.home, "Home", 0),
                _buildNavItem(Icons.favorite, "Adopted", 1),
                _buildNavItem(Icons.card_giftcard, "Give Away", 2),
                _buildNavItem(Icons.info, "About", 3),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHomePage(),
                _buildAdoptedDogsPage(),
                _buildGiveAwayDogsPage(),
                _buildAboutMePage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, color: _selectedIndex == index ? Colors.orange : Colors.white, size: 30),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: _selectedIndex == index ? Colors.orange : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Discover Your Ideal Furry Companion!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),  
          Text("Provide a Warm and Loving Home to a Dog in Need.", style: TextStyle(fontSize: 14)),  
          Text("Select a Breed to Begin Your Journey", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),  

          FutureBuilder<List<Breed>>(
            future: futureBreeds,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                var breeds = snapshot.data!;
                return DropdownButton<Breed>(
                value: selectedBreed,
                items: breeds.map((breed) => 
                  DropdownMenuItem(
                    value: breed,
                    child: Text(breed.name.toUpperCase()),
                  ),
                ).toList(),
                onChanged: (value) {
                  if (value != null) handleBreedSelection(value);
                },
                style: TextStyle(color: Colors.black),
                dropdownColor: Colors.white,
                focusColor: Colors.transparent,
                elevation: 0,
              );
              }
              return Text("No breeds found.");
            },
          ),
          if (hasSelection) ...[
            FutureBuilder<BreedImage>(
              future: futureSelectedImageUrl,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Column(
                    children: [
                      Image.network(snapshot.data!.imageUrl, height: 300),
                      Text(selectedBreed!.dogName.toUpperCase(), style: TextStyle(fontSize: 24)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(onPressed: adoptDog, child: Text("Adopt")),
                          SizedBox(width: 10),
                          ElevatedButton(onPressed: showNextBreed, child: Text("Show Next")),
                        ],
                      ),
                    ],
                  );
                }
                return SizedBox();
              },
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildAdoptedDogsPage() {
  return GridView.builder(
    padding: EdgeInsets.all(8),
    itemCount: adoptedDogs.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 0.9,
    ),
    itemBuilder: (context, index) {
      final dog = adoptedDogs[index];
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dog.breed.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  dog.image,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8),
              Text(
                dog.breed.dogName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    giveAwayDogs.add(dog);
                    adoptedDogs.removeAt(index);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  textStyle: TextStyle(fontSize: 12),
                  minimumSize: Size(80, 30),
                ),
                child: Text("Give Away"),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildGiveAwayDogsPage() {
  return GridView.builder(
    padding: EdgeInsets.all(8),
    itemCount: giveAwayDogs.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 0.9,
    ),
    itemBuilder: (context, index) {
      final dog = giveAwayDogs[index];
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dog.breed.dogName.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  dog.image,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8),
              Text(
                dog.breed.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    },
  );
}

 Widget _buildAboutMePage() {
  return Padding(
    padding: EdgeInsets.all(20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(
            "data:image/jpeg;base64,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"
          ),
        ),
        SizedBox(height: 15),
        Text(
          "Jhemar Anablon",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          "IT Student | King's College of the Philippines",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        SizedBox(height: 15),
        Text(
          "Hello! I'm Jhemar Anablon, a retired babaero of all time and a passionate motorcycle rider. I live for the thrill of the open road, where every ride is an adventure. Though my babaero days are behind me, the memories live on, and now, my heart belongs to the roar of my engine.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        SizedBox(height: 20)
      ],
    ),
  );
}
}

class BreedDog {
  final String name;
  final Breed breed;
  final String image;

  BreedDog({required this.name, required this.breed, required this.image});
}

class Breed {
  final String name;
  final String dogName;

  Breed({required this.name, required this.dogName});

  factory Breed.fromJson(String name) {
    return Breed(name: name, dogName: generateWordPairs().first.asPascalCase);
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

    return data['message'].keys.map<Breed>((name) {
      final randomDogName = generateWordPairs().first.asPascalCase;
      return Breed(name: name, dogName: randomDogName);
    }).toList();
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