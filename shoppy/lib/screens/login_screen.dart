// ignore_for_file: use_build_context_synchronously

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shoppy/models/product_model.dart';
import 'package:shoppy/screens/main_screen.dart';
import 'package:shoppy/services/provider/product_provider.dart';
import 'package:shoppy/services/provider/userdata_provider.dart';
import 'package:shoppy/widgets/register_textfield.dart';
import 'package:shoppy/widgets/welcome_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  Future<List<Product>> fetchProducts(String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          return jsonResponse.map((json) => Product.fromJson(json)).toList();
        } else if (jsonResponse is Map &&
            jsonResponse.containsKey('products')) {
          List<dynamic> productJson = jsonResponse['products'];
          return productJson.map((json) => Product.fromJson(json)).toList();
        } else {
          throw Exception('Unexpected products API response format');
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching products: $error');
    }
  }

  Future<void> loginUser() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/login'),
        body: json.encode({
          'username': username,
          'password': password,
        }),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final token = responseBody['access_token'];
        Provider.of<UserData>(context, listen: false).setAccessToken(token);
        final products = await fetchProducts(token);
        Provider.of<ProductProvider>(context, listen: false)
            .setProducts(products);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(),
          ),
        );
      } else {
        showSnackBar('Login Failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      showSnackBar('An error occurred: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 52),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.asset(
                      "assets/images/login.webp",
                      height: 400,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  "Welcome back !",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32),
                RegisterTextfield(
                    controller: _usernameController, hintText: "Username"),
                SizedBox(height: 12),
                RegisterTextfield(
                  controller: _passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),
                SizedBox(height: 20),
                isLoading
                    ? CircularProgressIndicator()
                    : WelcomeButton(onPressed: loginUser, title: "Login")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
