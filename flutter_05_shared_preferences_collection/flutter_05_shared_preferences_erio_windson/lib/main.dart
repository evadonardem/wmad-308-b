import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
      _darkMode = prefs.getBool('Dark Mode') ?? false;
      _setting1 = prefs.getBool('Setting 1') ?? false;
      _setting2 = prefs.getBool('Setting 2') ?? false;
      _setting3 = prefs.getBool('Setting 3') ?? false;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool(key, value);
      if (key == 'Dark Mode') _darkMode = value;
      if (key == 'Setting 1') _setting1 = value;
      if (key == 'Setting 2') _setting2 = value;
      if (key == 'Setting 3') _setting3 = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _darkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('User Preferences'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildSwitchTile('Dark Mode', 'Dark Mode', _darkMode, Icons.dark_mode),
              _buildSwitchTile('Enable Setting 1', 'Setting 1', _setting1, Icons.settings),
              _buildSwitchTile('Enable Setting 2', 'Setting 2', _setting2, Icons.settings),
              _buildSwitchTile('Enable Setting 3', 'Setting 3', _setting3, Icons.settings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String key, bool value, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18),
      ),
      trailing: Switch(
        value: value,
        activeColor: const Color.fromARGB(255, 212, 54, 244), 
        onChanged: (bool newValue) => _updateSetting(key, newValue),
      ),
    );
  }
}
