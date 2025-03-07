import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Shared preferences',
      home: MyHomePage(title: 'Shared preferences'),
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
  bool _isDarkMode = false;
  bool _settings1 = false;
  bool _settings2 = false;
  bool _settings3 = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _settings1 = prefs.getBool('notifications') ?? false;
      _settings2 = prefs.getBool('autoSave') ?? false;
      _settings3 = prefs.getBool('syncData') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', _isDarkMode);
    prefs.setBool('notifications', _settings1);
    prefs.setBool('autoSave', _settings2);
    prefs.setBool('syncData', _settings3);
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    _saveSettings();
  }

  void _toggleSettings1(bool value) {
    setState(() {
      _settings1 = value;
    });
    _saveSettings();
  }

  void _toggleSettings2(bool value) {
    setState(() {
      _settings2 = value;
    });
    _saveSettings();
  }

  void _toggleSettings3(bool value) {
    setState(() {
      _settings3 = value;
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Enable dark theme'),
                    value: _isDarkMode,
                    onChanged: _toggleDarkMode,
                  ),
                  SwitchListTile(
                    title: const Text('Settings 1'),
                    subtitle: const Text('SETTINGS 1'),
                    value: _settings1,
                    onChanged: _toggleSettings1,
                  ),
                  SwitchListTile(
                    title: const Text('Settings 2'),
                    subtitle: const Text('SETTINGS 2'),
                    value: _settings2,
                    onChanged: _toggleSettings2,
                  ),
                  SwitchListTile(
                    title: const Text('Settings 3'),
                    subtitle: const Text('SETTINGS 3'),
                    value: _settings3,
                    onChanged: _toggleSettings3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}