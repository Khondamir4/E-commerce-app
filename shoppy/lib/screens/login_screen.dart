import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shoppy/models/product_model.dart';
import 'package:shoppy/screens/product_list_screen.dart';

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

      print('Products API Response: ${response.body}');

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
        var responseBody = json.decode(response.body);
        String token = responseBody['access_token'];
        List<Product> products = await fetchProducts(token);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductListScreen(products: products),
          ),
        );
      } else {
        showSnackBar('Login Failed with status code: ${response.statusCode}');
        print('Login Failed: ${response.body}');
      }
    } catch (error) {
      showSnackBar('An error occurred: $error');
      print('Error: $error');
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
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: "Username",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(width: 1.5, color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(width: 1.5, color: Colors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(width: 1.5, color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(width: 1.5, color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(width: 1.5, color: Colors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(width: 1.5, color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                isLoading
                    ? CircularProgressIndicator()
                    : OutlinedButton(
                        onPressed: loginUser,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 48,
                          ),
                          backgroundColor: Colors.black,
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}