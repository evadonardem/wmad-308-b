import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shared Preferences Demo',
      home: MyHomePage(title: 'Shared Preferences Demo'),
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
  bool _darkMode = false;
  bool _setting1 = false;
  bool _setting2 = false;
  bool _setting3 = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _setting1 = prefs.getBool('setting1') ?? false;
      _setting2 = prefs.getBool('setting2') ?? false;
      _setting3 = prefs.getBool('setting3') ?? false;
    });
  }

  Future<void> _toggleSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool(key, value);

      if (key == 'darkMode') {
        _darkMode = value;
      } else {
        _setting1 = key == 'setting1' ? value : false;
        _setting2 = key == 'setting2' ? value : false;
        _setting3 = key == 'setting3' ? value : false;
      }
    });
  }

  /// Returns the background color based on the settings
  Color _getBackgroundColor() {
    if (_darkMode) return Colors.black; // Dark mode background
    if (_setting1) return const Color.fromARGB(255, 64, 107, 236); // Light blue
    if (_setting2) return const Color.fromARGB(255, 231, 51, 51); // Light red
    if (_setting3) return const Color.fromARGB(255, 36, 226, 84); // Light green
    return Colors.white;
  }

  /// Custom switch builder to adjust color dynamically
  Widget _buildSwitch(String label, bool value, String key, Color darkModeColor, Color lightModeColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            color: _darkMode ? Colors.white : const Color.fromARGB(255, 44, 44, 44), // Adjust text color in dark mode
          ),
        ),
        Switch(
          value: value,
          activeColor: _darkMode ? Colors.white : lightModeColor, // Light color in dark mode
          onChanged: (bool newValue) {
            _toggleSetting(key, newValue);
          },
        ),
        if (value)
          Text(
            '$label is ON',
            style: TextStyle(
              fontSize: 15,
              color: _darkMode ? Colors.white : Colors.black,
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: _darkMode ? const Color.fromARGB(255, 158, 158, 158) : Colors.blue,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: _getBackgroundColor(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSwitch('Dark Mode', _darkMode, 'darkMode', Colors.white, Colors.black),
              _buildSwitch('Setting 1', _setting1, 'setting1', Colors.white, Colors.blue),
              _buildSwitch('Setting 2', _setting2, 'setting2', Colors.white, const Color.fromARGB(255, 245, 93, 82)),
              _buildSwitch('Setting 3', _setting3, 'setting3', Colors.white, Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}
