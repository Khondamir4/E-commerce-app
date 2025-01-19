import 'package:flutter/material.dart';
import 'package:shoppy/screens/main_screen.dart';
//import 'package:shoppy/screens/welcome_screen.dart';
//import 'screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce App',
      theme: ThemeData(
        fontFamily: "Merriweather",
      ),
      home: MainScreen(),
    );
  }
}
