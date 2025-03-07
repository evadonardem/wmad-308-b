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
  bool _switch1 = false;
  bool _switch2 = false;
  bool _switch3 = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load preferences for counter, theme, and switches.
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _switch1 = prefs.getBool('switch1') ?? false;
      _switch2 = prefs.getBool('switch2') ?? false;
      _switch3 = prefs.getBool('switch3') ?? false;
    });
  }

  // Save preferences for counter, theme, and switches.
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt('counter', _counter);
    prefs.setBool('isDarkMode', _isDarkMode);
    prefs.setBool('switch1', _switch1);
    prefs.setBool('switch2', _switch2);
    prefs.setBool('switch3', _switch3);
  }

  // Increment counter and save it to SharedPreferences.
  Future<void> _incrementCounter() async {
    setState(() {
      _counter++;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('counter', _counter);
  }

  // Toggle the dark mode theme and save the preference.
  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    _savePreferences();
  }

  // Handle the switch changes and save the preferences.
  void _onSwitchChanged(int switchIndex, bool value) {
    setState(() {
      if (switchIndex == 1) {
        _switch1 = value;
      } else if (switchIndex == 2) {
        _switch2 = value;
      } else if (switchIndex == 3) {
        _switch3 = value;
      }
    });
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You have pushed the button this many times: '),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: _isDarkMode,
                onChanged: _toggleDarkMode,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Switch 1'),
                value: _switch1,
                onChanged: (bool value) => _onSwitchChanged(1, value),
              ),
              SwitchListTile(
                title: const Text('Switch 2'),
                value: _switch2,
                onChanged: (bool value) => _onSwitchChanged(2, value),
              ),
              SwitchListTile(
                title: const Text('Switch 3'),
                value: _switch3,
                onChanged: (bool value) => _onSwitchChanged(3, value),
              ),
            ],
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
