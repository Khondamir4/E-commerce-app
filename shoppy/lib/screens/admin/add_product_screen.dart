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
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  File? _selectedImage;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Send Product Details & Image as Multipart Request
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

    if (_selectedImage == null) {
      _showSnackBar("Please select an image");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Prepare a multipart request for sending the data
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/products'),
      );
      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      // Add other form data fields
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['price'] = double.tryParse(price)?.toString() ?? '0.0';
      request.fields['quantity'] = int.tryParse(quantity)?.toString() ?? '0';

      // Add image as multipart
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 201) {
        _showSnackBar("Product added successfully!");
        Navigator.pop(context); // Go back after successful upload
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
              SizedBox(height: 12),
              _selectedImage == null
                  ? Text("No image selected")
                  : Image.file(_selectedImage!, height: 150),
              ElevatedButton(
                onPressed: _selectImage,
                child: Text("Select Image"),
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
