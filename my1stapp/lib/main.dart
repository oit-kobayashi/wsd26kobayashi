import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
  int _counter = 1;
  int _maxCounter = 1;
  SharedPreferences? _sp;
  String _message = "(message)";

  void _setCounter(int c) {
    setState(() {
      _counter = c;
    });
    if (_counter > _maxCounter) {
      _maxCounter = _counter;
    }
    if (_sp != null) {
      unawaited(_sp!.setInt('count', _maxCounter));
    }
    final db = FirebaseFirestore.instance;
    db.collection("state").doc("current").set({"count": _counter});
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((sp) {
      _sp = sp;
      _setCounter(sp.getInt('count') ?? 0);
    });
    final ref = FirebaseFirestore.instance.collection("messages").doc("new");
    ref.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        print(data);
        if (data != null) {
          setState(() {
            _message = data["message"];
          });
        }
      }
    });
    // 天気取得
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?id=1853908&appid=cbcaed84cb5e809e27efd7b8ec30f7e9',
    );
    http.get(url).then((resp) {
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final weather = (data['weather'] as List)[0];
        final desc = weather['description'] as String;
        final icon = weather['icon'] as String;
        print(desc);
        print(icon);
        final urlS =
            "https://openweathermap.org/payload/api/media/file/$icon.png";
      }
    });
    super.initState();
  }

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
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          "https://picsum.photos/seed/$_counter/400/300",
                        ),
                      ),
                      Text("count: $_counter"),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: FittedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              _setCounter(_counter + 1);
                            },
                            child: Text("+1"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              _setCounter(_counter - 1);
                            },
                            child: Text("-1"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              _setCounter(0);
                            },
                            child: Icon(Icons.refresh),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          child: ElevatedButton(
                            onPressed: () async {
                              final url = Uri.parse(
                                "https://jsonplaceholder.typicode.com/posts",
                              );
                              final data = {
                                'title': 'test you',
                                'body': 'by kobayashi',
                                'userId': 5,
                              };
                              final resp = await http.post(
                                url,
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode(data),
                              );
                              print("status: ${resp.statusCode}");
                              print("body: ${resp.body}");
                            },
                            child: Text("POST"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(_message, style: TextStyle(fontSize: 24)),
                TextField(
                  onSubmitted: (s) {
                    final db = FirebaseFirestore.instance;
                    db.collection("messages").doc("new").set({"message": s});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
