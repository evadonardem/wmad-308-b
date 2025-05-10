import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMB | Shared preferences',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'SMB | Shared preferences'),
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
      switch (key) {
        case 'darkMode':
          _darkMode = value;
          break;
        case 'setting1':
          _setting1 = value;
          break;
        case 'setting2':
          _setting2 = value;
          break;
        case 'setting3':
          _setting3 = value;
          break;
      }
    });
  }

  Color _getBackgroundColor() {
    return _darkMode ? Colors.black : Colors.white;
  }

  Color _getTextColor() {
    return _darkMode ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: _getTextColor())),
        backgroundColor: _darkMode ? Colors.grey[900] : const Color.fromARGB(255, 213, 190, 255),
      ),
      body: Container(
        color: _getBackgroundColor(),
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildSwitchTile('Dark Mode', _darkMode, 'darkMode'),
            _buildSwitchTile('Setting 1', _setting1, 'setting1'),
            _buildSwitchTile('Setting 2', _setting2, 'setting2'),
            _buildSwitchTile('Setting 3', _setting3, 'setting3'),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, String key) {
    return Card(
      color: _darkMode ? Colors.grey[800] : Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _getTextColor())),
            Switch(
              value: value,
              onChanged: (bool newValue) => _toggleSetting(key, newValue),
              activeColor: const Color.fromARGB(255, 211, 184, 255),
              inactiveTrackColor: const Color.fromARGB(255, 255, 231, 239),
            ),
            if (value) Text('$title is ON', style: TextStyle(color: _getTextColor())),
          ],
        ),
      ),
    );
  }
}