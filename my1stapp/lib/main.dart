import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kobayashi App',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.lightGreen)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                //Expanded(flex: 2, child: Text("count: $_counter")),
                Expanded(
                  flex: 2,
                  child: Image.network(
                    "https://picsum.photos/seed/$_counter/400/300",
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: FittedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _counter++;
                              });
                            },
                            child: Icon(Icons.plus_one),
                          ),
                        ),
                      ),
                      Expanded(child: Placeholder()),
                      Expanded(child: Placeholder()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Placeholder()),
        ],
      ),
    );
  }
}
