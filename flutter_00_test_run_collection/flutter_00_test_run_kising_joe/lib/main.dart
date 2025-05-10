import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 223, 12, 12)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Test Run by Joe Kis-Ing'),
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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  void _counterDirection(bool isIncrement) {
    setState(() {
      if (isIncrement) {
        _counter++;
      } else {
        _counter--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Your bill per "Click":',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _counterDirection(false),
                  child: const Icon(Icons.accessibility_new_sharp),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () => _counterDirection(true),
                  tooltip: 'Increment',
                  child: const Icon(Icons.add_reaction_outlined),
                ),
              ],
            ),
                              Text('My Name is Joe'),
          ],
        ),
      ),
    );
  }
}
