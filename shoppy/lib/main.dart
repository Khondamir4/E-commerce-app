import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppy/screens/welcome_screen.dart';
import 'package:shoppy/services/provider/cart_provider.dart';
import 'package:shoppy/services/provider/product_provider.dart';
import 'package:shoppy/services/provider/userdata_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserData()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MyApp(),
    ),
  );
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
