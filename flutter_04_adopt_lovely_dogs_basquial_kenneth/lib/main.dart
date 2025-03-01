import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:english_words/english_words.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

void _launchFacebook() async {
  final Uri url = Uri.parse("https://www.facebook.com/kinnith221/");

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw Exception("Could not launch $url");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(151, 74, 8, 105),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Lovely Dogs By Basquial Kenneth'),
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
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: const Color.fromARGB(255, 136, 150, 231),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Adopted Dogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Give Away Dogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'About Me',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Welcome to our Dog Adoption Page!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("You can adopt your favorite!", style: TextStyle(fontSize: 14)),
          Text("Select a Dog Breed", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
  return ListView.separated(
    padding: EdgeInsets.all(10),
    itemCount: adoptedDogs.length,
    separatorBuilder: (context, index) => SizedBox(height: 20),
    itemBuilder: (context, index) {
      final dog = adoptedDogs[index];
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(dog.image, height: 100, width: 100, fit: BoxFit.cover),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dog.breed.dogName.toUpperCase(),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      dog.breed.name.toUpperCase(),
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    giveAwayDogs.add(dog);
                    adoptedDogs.removeAt(index);
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text("Give It Away"),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildGiveAwayDogsPage() {
  return ListView.separated(
    padding: EdgeInsets.all(10),
    itemCount: giveAwayDogs.length,
    separatorBuilder: (context, index) => SizedBox(height: 20),
    itemBuilder: (context, index) {
      final dog = giveAwayDogs[index];
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(dog.image, height: 100, width: 100, fit: BoxFit.cover),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dog.breed.dogName.toUpperCase(),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      dog.breed.name.toUpperCase(),
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
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
            "https://scontent.fmnl17-1.fna.fbcdn.net/v/t39.30808-6/447472440_2737732713049328_6492872743207154016_n.jpg?_nc_cat=101&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeGhOvLuK0t-toXFEV-GhAOwPo2b3LCCPk0-jZvcsII-TW3jQv0heppGgSi_SlpenJdCkIkOoo3o0GorxCQkquWJ&_nc_ohc=lhJLMIqARUoQ7kNvgF9UB2e&_nc_oc=AdjnlAzX2LqggLzfcXZDjZqVSn_tU-HpsoSSOiVsy6Ds_XJUpYiGNeWq_1HmYVQSDMg&_nc_zt=23&_nc_ht=scontent.fmnl17-1.fna&_nc_gid=AYvepSqAuEQp_dr5H8f05Jp&oh=00_AYCAlyl-NJR9Z0JcaKemxsBzBmEd9oHf0RZJ7k9Zs-Udtw&oe=67C8B49F", // Replace with your actual profile image URL
          ),
        ),
        SizedBox(height: 15),
        Text(
          "Kenneth Basquial",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          "IT Student | King's College of the Philippines",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        SizedBox(height: 15),
        Text(
          "Hello! I'm Kenneth Basquial, a 20-year-old IT student at King's College of the Philippines. "
          "I am passionate about software development and love building applications that solve real-world problems. "
          "Currently, I am exploring Flutter and mobile app development!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        SizedBox(height: 20),
        ElevatedButton.icon(
         onPressed: _launchFacebook,
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