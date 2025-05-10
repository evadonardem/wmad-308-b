import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final setting1 = prefs.getBool('setting1') ?? false;
  final setting2 = prefs.getBool('setting2') ?? false;
  final setting4 = prefs.getBool('setting4') ?? false;

  runApp(MyApp(
    isDarkMode: isDarkMode,
    setting1: setting1,
    setting2: setting2,
    setting4: setting4,
  ));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  final bool setting1;
  final bool setting2;
  final bool setting4;

  const MyApp({super.key, required this.isDarkMode, required this.setting1, required this.setting2, required this.setting4});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;
  late bool _setting1;
  late bool _setting2;
  late bool _setting4;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _setting1 = widget.setting1;
    _setting2 = widget.setting2;
    _setting4 = widget.setting4;
  }

  void _toggleSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() {
      switch (key) {
        case 'isDarkMode':
          _isDarkMode = value;
          break;
        case 'setting1':
          _setting1 = value;
          break;
        case 'setting2':
          _setting2 = value;
          break;
        case 'setting4':
          _setting4 = value;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dark Mode and Settings Preferences',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MyHomePage(
        onSettingChanged: _toggleSetting,
        isDarkMode: _isDarkMode,
        setting1: _setting1,
        setting2: _setting2,
        setting4: _setting4,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final Function(String, bool) onSettingChanged;
  final bool isDarkMode;
  final bool setting1;
  final bool setting2;
  final bool setting4;

  const MyHomePage({
    super.key,
    required this.onSettingChanged,
    required this.isDarkMode,
    required this.setting1,
    required this.setting2,
    required this.setting4,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dark Mode and Settings Preferences')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (value) => onSettingChanged('isDarkMode', value),
          ),
          SwitchListTile(
            title: const Text('Setting 1'),
            value: setting1,
            onChanged: (value) => onSettingChanged('setting1', value),
          ),
          SwitchListTile(
            title: const Text('Setting 2'),
            value: setting2,
            onChanged: (value) => onSettingChanged('setting2', value),
          ),
          SwitchListTile(
            title: const Text('Setting 4'),
            value: setting4,
            onChanged: (value) => onSettingChanged('setting4', value),
          ),
        ],
      ),
    );
  }
}