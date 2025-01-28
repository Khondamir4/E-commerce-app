// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppy/services/provider/userdata_provider.dart';
import 'package:shoppy/widgets/checkout_button.dart';
import 'package:shoppy/widgets/location_textfield.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Text controllers for form fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  // Image file for the product
  File? _selectedImage;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  /// Method to pick an image from the gallery
  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// Validates form inputs and displays relevant errors
  bool _validateInputs() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = _priceController.text.trim();
    final quantity = _quantityController.text.trim();

    if (name.isEmpty ||
        description.isEmpty ||
        price.isEmpty ||
        quantity.isEmpty) {
      _showSnackBar("Please fill in all the fields");
      return false;
    }
    if (_selectedImage == null) {
      _showSnackBar("Please select an image");
      return false;
    }
    return true;
  }

  /// Adds a product by sending a multipart HTTP request
  Future<void> _addProduct() async {
    if (!_validateInputs()) return;

    final userDataProvider = Provider.of<UserData>(context, listen: false);
    final token = userDataProvider.accessToken;

    setState(() {
      isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/products'),
      );

      // Attach headers
      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      // Add fields
      request.fields['name'] = _nameController.text.trim();
      request.fields['description'] = _descriptionController.text.trim();
      request.fields['price'] =
          double.tryParse(_priceController.text.trim())?.toString() ?? '0.0';
      request.fields['quantity'] =
          int.tryParse(_quantityController.text.trim())?.toString() ?? '0';

      // Attach image
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        ),
      );

      // Send the request and handle response
      final response = await request.send();
      if (response.statusCode == 201) {
        _showSnackBar("Product added successfully!");
        Navigator.pop(context); // Navigate back to the previous screen
      } else {
        final responseBody = await response.stream.bytesToString();
        final errorData = json.decode(responseBody);
        _showSnackBar("Failed to add product: ${errorData['detail']}");
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Displays a snack bar with a given message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocationTextfield(
                  controller: _nameController,
                  hintText: "Name",
                ),
                const SizedBox(height: 12),
                LocationTextfield(
                  controller: _descriptionController,
                  hintText: "Description",
                ),
                const SizedBox(height: 12),
                LocationTextfield(
                  controller: _priceController,
                  hintText: "Price",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                LocationTextfield(
                  controller: _quantityController,
                  hintText: "Quantity",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _selectedImage == null
                    ? const Text("No image selected",
                        style: TextStyle(color: Colors.grey))
                    : Image.file(
                        _selectedImage!,
                        height: 150,
                      ),
                ElevatedButton(
                  onPressed: _selectImage,
                  child: const Text("Select Image"),
                ),
                const SizedBox(height: 24),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CheckoutButton(
                        onPressed: _addProduct,
                        title: "Add Product",
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
