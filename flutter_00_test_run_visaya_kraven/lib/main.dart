import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test Run by Kraven Visaya',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 40, 119, 47)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Test Run Home Page by Kraven Visaya'),
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


  void _counterDirection(bool isIncrement){
    setState(() {
      _counter += isIncrement ? 1 : -1;
    });
  }
  
  // void _incrementCounter() {
  //   setState(() {
      
  //     _counter++;
  //   });
  // }

  // void decrementCounter() {
  //   setState(() {
      
  //     _counter--;
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
              'Add Substract',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: ()=> _counterDirection(true), child: Icon(Icons.plus_one)),
                ElevatedButton(onPressed: ()=> _counterDirection(false), child: Icon(Icons.exposure_minus_1))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
