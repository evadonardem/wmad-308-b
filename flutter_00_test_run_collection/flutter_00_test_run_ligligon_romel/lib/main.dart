import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter test run by Romel Ligligon',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 67, 153, 142)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Test Run Home Page by Romel Ligligon'),
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
    setState((){
     _counter += isIncrement ? 1000 : -1;
    });
}

  // void_incrementCounter() {
  //   setState(() {
      
  //     _counter++;
  //   });
  // }

  // void_decrementCounter() {
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
              'Push if your handsome',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () => _counterDirection(false), 
                child: Icon(Icons.arrow_circle_down_outlined)
                ),
                ElevatedButton(onPressed: () => _counterDirection(true), 
                child: Icon(Icons.arrow_circle_up_outlined)
                ),
              ],
            ),
            Text("Pogi ako masyado..."),
          ],
        ),
      ), 
    );
  }
}
