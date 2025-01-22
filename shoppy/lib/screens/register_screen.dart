// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shoppy/models/product_model.dart';
import 'dart:convert';
import 'package:shoppy/screens/main_screen.dart';
import 'package:shoppy/services/provider/product_provider.dart';
import 'package:shoppy/services/provider/userdata_provider.dart';
import 'package:shoppy/widgets/login_link.dart';
import 'package:shoppy/widgets/register_textfield.dart';
import 'package:shoppy/widgets/welcome_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
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
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to fetch products: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    }
  }

  Future<void> registerUser() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String fullName = _fullNameController.text.trim();
    String password = _passwordController.text;

    if (username.isEmpty ||
        email.isEmpty ||
        fullName.isEmpty ||
        password.isEmpty) {
      _showSnackBar("All fields are required.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "full_name": fullName,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
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
        _showSnackBar(
            "Registration failed: ${response.statusCode} - ${response.body}");
      }
    } catch (error) {
      _showSnackBar("An error occurred: $error");
      debugPrint('Error during registration: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.asset(
                        "assets/images/reg.jpg",
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    "Unique Furniture To Decor \n Your Home",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 32),
                  RegisterTextfield(
                    controller: _fullNameController,
                    hintText: "Full Name",
                  ),
                  SizedBox(height: 12),
                  RegisterTextfield(
                    controller: _emailController,
                    hintText: "Email",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 12),
                  RegisterTextfield(
                    controller: _usernameController,
                    hintText: "Username",
                  ),
                  SizedBox(height: 12),
                  RegisterTextfield(
                    controller: _passwordController,
                    hintText: "Password",
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  isLoading
                      ? const CircularProgressIndicator()
                      : WelcomeButton(
                          onPressed: registerUser, title: "Register"),
                  const SizedBox(height: 12),
                  LoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
