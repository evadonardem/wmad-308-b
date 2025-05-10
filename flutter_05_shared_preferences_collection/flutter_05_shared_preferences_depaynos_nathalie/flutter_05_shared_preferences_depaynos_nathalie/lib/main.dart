import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _preferences = {
    'darkMode': false,
    'setting1': false,
    'setting2': false,
    'setting3': false,
  };

  Map<String, bool> settings = Map.from(_preferences);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      settings.forEach((key, value) {
        settings[key] = prefs.getBool(key) ?? value;
      });
    });
  }

  Future<void> _togglePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (settings[key] != value) {
        settings[key] = value;
        prefs.setBool(key, value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings by Depaynos, Nathalie',
      theme: settings['darkMode']! ? ThemeData.dark() : ThemeData.light(),
      home: MyHomePage(
        title: 'Settings',
        settings: settings,
        onPreferenceChanged: _togglePreference,
        backgroundColor: settings['darkMode']! ? Colors.black : Colors.white,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final Map<String, bool> settings;
  final Function(String, bool) onPreferenceChanged;
  final Color backgroundColor;

  const MyHomePage({
    super.key,
    required this.title,
    required this.settings,
    required this.onPreferenceChanged,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final settingLabels = {
      'darkMode': 'Dark Mode',
      'setting1': 'Setting 1',
      'setting2': 'Setting 2',
      'setting3': 'Setting 3',
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
        color: backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: settingLabels.keys.map((key) {
              return Column(
                children: [
                  Text(settingLabels[key]!),
                  const SizedBox(height: 5),
                  Switch(
                    value: settings[key]!,
                    onChanged: (value) => onPreferenceChanged(key, value),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
