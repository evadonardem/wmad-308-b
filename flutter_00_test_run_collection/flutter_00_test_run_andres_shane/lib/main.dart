import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test Run By Yours: Andres Shane M',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 1, 12, 3)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Test Run Homepage By Him: Andres Shane M'),
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

  _counterDirection(bool isIncrement){
    setState(() {
      _counter += isIncrement ? 1: -1;
    });
  }
  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  // void _decrementCounter() {
  //   setState(() {
  //     if (_counter > 0) {
  //       _counter--;
  //     }
  //   });
  // }

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
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _counterDirection(false),
                  child: const Icon(Icons.circle),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _counterDirection(true),
                  child: const Icon(Icons.square),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'My Name is Shintot',
              style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 172, 39, 39)),
            ),
          ],
        ),
      ),
    );
  }
}