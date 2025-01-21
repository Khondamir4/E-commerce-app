import 'package:flutter/material.dart';
import 'package:shoppy/screens/welcome_screen.dart';

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
      home: WelcomeScreen(),
    );
  }
}
