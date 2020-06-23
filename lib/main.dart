import 'package:flutter/material.dart';
import 'package:shareit/pages/home.dart';

void main() {
  //Firestore.instance.settings(persistenceEnabled: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        accentColor: Colors.deepPurple,
      ),
      title: 'FlutterShare',
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

