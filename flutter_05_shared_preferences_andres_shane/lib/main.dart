import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shared Preferences Demo',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: MyHomePage(title: 'Shared Preferences Demo', isDarkMode: _isDarkMode, onThemeChanged: _toggleTheme),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.isDarkMode, required this.onThemeChanged});

  final String title;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _switch1 = false;
  bool _switch2 = false;
  bool _switch3 = false;

  @override
  void initState() {
    super.initState();
    _loadCounter();
    _loadSwitchStates();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
    });
  }

  Future<void> _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = (prefs.getInt('counter') ?? 0) + 1;
      prefs.setInt('counter', _counter);
    });
  }

  Future<void> _loadSwitchStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _switch1 = prefs.getBool('switch1') ?? false;
      _switch2 = prefs.getBool('switch2') ?? false;
      _switch3 = prefs.getBool('switch3') ?? false;
    });
  }

  Future<void> _saveSwitchState(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true, elevation: 4, backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.blue),
      body: Center(
        child: Card(
          elevation: 5,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('You have pushed the button this many times:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: widget.isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text("Dark Mode"),
                  value: widget.isDarkMode,
                  onChanged: widget.onThemeChanged,
                  secondary: const Icon(Icons.dark_mode),
                ),
                SwitchListTile(
                  title: const Text("Switch 1"),
                  value: _switch1,
                  onChanged: (value) {
                    setState(() => _switch1 = value);
                    _saveSwitchState('switch1', value);
                  },
                  secondary: const Icon(Icons.toggle_on),
                ),
                SwitchListTile(
                  title: const Text("Switch 2"),
                  value: _switch2,
                  onChanged: (value) {
                    setState(() => _switch2 = value);
                    _saveSwitchState('switch2', value);
                  },
                  secondary: const Icon(Icons.toggle_on),
                ),
                SwitchListTile(
                  title: const Text("Switch 3"),
                  value: _switch3,
                  onChanged: (value) {
                    setState(() => _switch3 = value);
                    _saveSwitchState('switch3', value);
                  },
                  secondary: const Icon(Icons.toggle_on),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
        backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors.blue,
      ),
    );
  }
}
