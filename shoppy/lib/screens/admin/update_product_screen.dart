// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shoppy/models/product_model.dart';
import 'package:shoppy/services/provider/product_provider.dart';
import 'package:shoppy/services/provider/userdata_provider.dart';
import 'package:shoppy/widgets/location_textfield.dart';
import 'package:shoppy/widgets/checkout_button.dart';
import 'package:http/http.dart' as http;

class UpdateProductScreen extends StatefulWidget {
  const UpdateProductScreen({super.key});

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  Product? selectedProduct;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> updateProduct(
      int productId, Map<String, dynamic> productData, File? imageFile) async {
    final String url = 'http://10.0.2.2:8000/products/$productId';
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    final token = userDataProvider.accessToken;

    final headers = {'Authorization': 'Bearer $token'};
    final request = http.MultipartRequest('PUT', Uri.parse(url))
      ..headers.addAll(headers)
      ..fields.addAll(
        productData.map(
          (key, value) => MapEntry(
            key,
            value.toString(),
          ),
        ),
      );

    if (imageFile != null) {
      final imageStream = http.ByteStream(imageFile.openRead());
      final imageLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'image',
        imageStream,
        imageLength,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);
    }

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to update product');
    }
  }

  void _updateProduct(
      BuildContext context, ProductProvider productProvider) async {
    if (selectedProduct != null) {
      final updatedProductData = {
        'name': nameController.text,
        'description': descriptionController.text,
        'price': double.tryParse(priceController.text)?.toString() ?? '0',
        'quantity': int.tryParse(quantityController.text)?.toString() ?? '0',
      };

      try {
        await updateProduct(
            selectedProduct!.id, updatedProductData, _selectedImage);
        productProvider.removeProduct(selectedProduct!.id);
        productProvider.addProduct(Product(
          id: selectedProduct!.id,
          name: nameController.text,
          description: descriptionController.text,
          price: double.tryParse(priceController.text) ?? 0,
          quantity: int.tryParse(quantityController.text) ?? 0,
        ));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedProduct!.name} updated successfully!'),
          ),
        );

        setState(() {
          selectedProduct = null;
          _selectedImage = null;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update product')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: selectedProduct == null
            ? _buildProductSelection(productProvider)
            : _buildProductUpdateForm(),
      ),
    );
  }

  Widget _buildProductSelection(ProductProvider productProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a product to update:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              final product = productProvider.products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('Price: \$${product.price}'),
                onTap: () {
                  setState(() {
                    selectedProduct = product;
                    nameController.text = product.name;
                    descriptionController.text = product.description;
                    priceController.text = product.price.toString();
                    quantityController.text = product.quantity.toString();
                  });
                },
                trailing: const Icon(Icons.edit),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductUpdateForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Update Product Details:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LocationTextfield(
            hintText: 'Name',
            controller: nameController,
          ),
          const SizedBox(height: 12),
          LocationTextfield(
            hintText: 'Description',
            controller: descriptionController,
          ),
          const SizedBox(height: 12),
          LocationTextfield(
            hintText: 'Price',
            controller: priceController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          LocationTextfield(
            hintText: 'Quantity',
            controller: quantityController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _selectImage,
            child: const Text("Select Image"),
          ),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Image.file(
                _selectedImage!,
                height: 150,
              ),
            ),
          const SizedBox(height: 24),
          CheckoutButton(
            title: 'Update',
            onPressed: () {
              _updateProduct(context,
                  Provider.of<ProductProvider>(context, listen: false));
            },
          ),
        ],
      ),
    );
  }
}
