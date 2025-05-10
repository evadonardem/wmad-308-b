import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Shared preferences demo',
      home: MyHomePage(title: 'Shared preferences demo'),
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
  int _counter = 0;
  bool _isDarkMode = false;
  bool _setting1 = false;
  bool _setting2 = false;
  bool _setting3 = false;

  @override
  void initState() {
    super.initState();
    _loadCounter();
    _loadThemePreference();
    _loadSettings();
  }

  // Load the initial counter value from persistent storage
  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
    });
  }

  // Load the dark mode preference from persistent storage
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Load the settings (switch values) from persistent storage
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _setting1 = prefs.getBool('setting1') ?? false;
      _setting2 = prefs.getBool('setting2') ?? false;
      _setting3 = prefs.getBool('setting3') ?? false;
    });
  }

  // Toggle dark mode
  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }

  // Increment the counter
  Future<void> _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = (prefs.getInt('counter') ?? 0) + 1;
      prefs.setInt('counter', _counter);
    });
  }

  // Toggle switches 1, 2, and 3
  Future<void> _toggleSwitch1(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _setting1 = value;
      prefs.setBool('setting1', _setting1);
    });
  }

  Future<void> _toggleSwitch2(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _setting2 = value;
      prefs.setBool('setting2', _setting2);
    });
  }

  Future<void> _toggleSwitch3(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _setting3 = value;
      prefs.setBool('setting3', _setting3);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('You have pushed the button this many times: '),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 30),
                // Dark Mode Switch
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.nightlight_round),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: _isDarkMode,
                      onChanged: _toggleDarkMode,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Setting Switch 1
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Setting 1'),
                    trailing: Switch(
                      value: _setting1,
                      onChanged: _toggleSwitch1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Setting Switch 2
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Setting 2'),
                    trailing: Switch(
                      value: _setting2,
                      onChanged: _toggleSwitch2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Setting Switch 3
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Setting 3'),
                    trailing: Switch(
                      value: _setting3,
                      onChanged: _toggleSwitch3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
