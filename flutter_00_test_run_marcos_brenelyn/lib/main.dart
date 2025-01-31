import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test Run by Brenelyn Marcos',
      theme: ThemeData(
       
        
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 99, 2, 2)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Test Run Home Page by Brenelyn Marcos' ),
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

  _counterDirection(bool isIncrement) {
    setState(() {
     _counter+= isIncrement ? 1 : -1;
    });
  }

//  void _incrementCounter() {
  //  setState(() {
      
 //     _counter+=2;
  //  });
//  }
 //void _decrementCounter() {
  //  setState(() {
      
   //   _counter--;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:  CrossAxisAlignment.center,
              children :[
              ElevatedButton(
              onPressed: () => {
                _counterDirection(false)
                },
             child: Icon(Icons.heart_broken_outlined)
             ) ,    
             ElevatedButton(
              onPressed: () => {
                 _counterDirection(true)
                 },
             child: Icon(Icons.heart_broken)
             ) ,    
              ]
          
            ),
            Text("Marcos, Brene"),
          ],
          
        ),
      ),
   //   floatingActionButton: FloatingActionButton(
   //     onPressed: ()=> _counterDirection(true),
   //     tooltip: 'Ouch, Dont Press Me',
    //    child: const Icon(Icons.heart_broken),
   //   ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
