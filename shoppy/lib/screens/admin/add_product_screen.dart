// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppy/services/provider/userdata_provider.dart';
import 'package:shoppy/widgets/checkout_button.dart';
import 'package:shoppy/widgets/location_textfield.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  bool isLoading = false;

  Future<void> addProduct() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = _priceController.text.trim();
    final quantity = _quantityController.text.trim();

    final userDataProvider = Provider.of<UserData>(context, listen: false);
    final token = userDataProvider.accessToken;

    if ([name, description, price, quantity].any((field) => field.isEmpty)) {
      _showSnackBar("Please fill all fields");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/products'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          'name': name,
          'description': description,
          'price': double.tryParse(price) ?? 0.0,
          'quantity': int.tryParse(quantity) ?? 0,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar("Product added successfully!");
        Navigator.pop(context);
      } else {
        final responseBody = json.decode(response.body);
        _showSnackBar("Failed to add product: ${responseBody['detail']}");
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              LocationTextfield(
                controller: _nameController,
                hintText: "Name",
              ),
              SizedBox(height: 12),
              LocationTextfield(
                controller: _descriptionController,
                hintText: "Description",
              ),
              SizedBox(height: 12),
              LocationTextfield(
                controller: _priceController,
                hintText: "Price",
              ),
              SizedBox(height: 12),
              LocationTextfield(
                controller: _quantityController,
                hintText: "Quantity",
              ),
              Expanded(child: SizedBox(height: 12)),
              isLoading
                  ? const CircularProgressIndicator()
                  : CheckoutButton(onPressed: addProduct, title: "Add Product"),
            ],
          ),
        ),
      ),
    );
  }
}
