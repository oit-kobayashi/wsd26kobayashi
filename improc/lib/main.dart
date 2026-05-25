import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: '画像変換アプリ'),
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
  Uint8List? _image;
  String _procedure = "gray";

  Future<void> _pickAndProc() async {
    final XFile? xf = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    final Uint8List? bs = await xf?.readAsBytes();
    if (bs != null) {
      final req = http.MultipartRequest(
        "POST",
        Uri.parse("https://improc.onrender.com/improc?procedure=$_procedure"),
      );
      req.files.add(
        http.MultipartFile.fromBytes("image_file", bs, filename: xf!.name),
      );
      final strmResp = await req.send();
      final resp = await http.Response.fromStream(strmResp);
      setState(() {
        _image = resp.bodyBytes;
      });
    }
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
          mainAxisAlignment: .center,
          children: [
            DropdownButton(
              value: _procedure,
              items: [
                DropdownMenuItem(value: "gray", child: Text("グレースケール")),
                DropdownMenuItem(value: "edge", child: Text("エッジ抽出")),
                DropdownMenuItem(value: "illust", child: Text("イラスト風")),
                DropdownMenuItem(value: "dummy", child: Text("元画像")),
              ],
              onChanged: (v) {
                setState(() {
                  _procedure = v ?? _procedure;
                });
              },
            ),
            _image != null ? Image.memory(_image!) : Placeholder(),
            ElevatedButton(onPressed: _pickAndProc, child: Text("画像選択")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndProc,
        tooltip: 'Increment',
        child: const Icon(Icons.image),
      ),
    );
  }
}
