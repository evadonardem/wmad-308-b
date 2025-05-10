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
      home: const MyHomePage(title: 'Lovely Dogs By Esguerra Aeron'),
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
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
    ),
    drawer: Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.pets, color: Colors.white, size: 50),
                SizedBox(height: 10),
                Text(
                  "Navigation",
                  style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.home, color: Colors.orange),
                  title: Text('Home'),
                  onTap: () => _onItemTapped(0),
                ),
                ListTile(
                  leading: Icon(Icons.favorite, color: Colors.red),
                  title: Text('Adopted Dogs'),
                  onTap: () => _onItemTapped(1),
                ),
                ListTile(
                  leading: Icon(Icons.card_giftcard, color: Colors.green),
                  title: Text('Give Away Dogs'),
                  onTap: () => _onItemTapped(2),
                ),
                ListTile(
                  leading: Icon(Icons.info, color: Colors.blue),
                  title: Text('About Me'),
                  onTap: () => _onItemTapped(3),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    body: IndexedStack(
      index: _selectedIndex,
      children: [
        _buildHomePage(),
        _buildAdoptedDogsPage(),
        _buildGiveAwayDogsPage(),
        _buildAboutMePage(),
      ],
    ),
  );
}

  Widget _buildHomePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Find Your Perfect Furry Friend!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),  
          Text("Give a loving home to a dog in need.", style: TextStyle(fontSize: 14)),  
          Text("Choose a Breed to Get Started", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),  

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
            "data:image/jpeg;base64,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",
          ),
        ),
        SizedBox(height: 15),
        Text(
          "Aeron Esguerra",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          "IT Student | King's College of the Philippines",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        SizedBox(height: 15),
        Text(
          "Hello! I'm Aeron Esguerra, an IT student at King's College of the Philippines. "
          "I lead my basketball team as the captain and enjoy the thrill of competition both on and off the court. "
          "Aside from sports and technology, I have a passion for strategic gambling, always seeking the next challenge. "
          "Known as the heartthrob of our school, I never fail to turn heads wherever I go.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
          },
          icon: Icon(Icons.contact_mail),
          label: Text("Contact Me"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
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