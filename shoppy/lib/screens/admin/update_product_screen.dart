import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppy/models/product_model.dart';
import 'package:shoppy/services/provider/product_provider.dart';
import 'package:shoppy/services/provider/userdata_provider.dart';
import 'package:shoppy/widgets/location_textfield.dart';
import 'package:shoppy/widgets/checkout_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<void> updateProduct(
      int productId, Map<String, dynamic> updatedProductData) async {
    final String url = 'http://10.0.2.2:8000/products/$productId';
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    final token = userDataProvider.accessToken;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(updatedProductData),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to update product');
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
            ? Column(
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
                        final product =
                            productProvider.products[index] as Product;
                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text('Price: \$${product.price}'),
                          onTap: () {
                            setState(() {
                              selectedProduct = product;
                              nameController.text = product.name;
                              descriptionController.text = product.description;
                              priceController.text = product.price.toString();
                              quantityController.text =
                                  product.quantity.toString();
                            });
                          },
                          trailing: const Icon(Icons.edit),
                        );
                      },
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Update Product Details:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 24),
                    CheckoutButton(
                      title: 'Update',
                      onPressed: () {
                        _updateProduct(context, productProvider);
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _updateProduct(
      BuildContext context, ProductProvider productProvider) async {
    if (selectedProduct != null) {
      final updatedProduct = Product(
        id: selectedProduct!.id,
        name: nameController.text,
        description: descriptionController.text,
        price: double.tryParse(priceController.text) ?? 0,
        quantity: int.tryParse(quantityController.text) ?? 0,
      );

      try {
        final updatedProductData = {
          'name': updatedProduct.name,
          'description': updatedProduct.description,
          'price': updatedProduct.price,
          'quantity': updatedProduct.quantity,
        };
        await updateProduct(updatedProduct.id, updatedProductData);
        productProvider.removeProduct(selectedProduct!.id);
        productProvider.addProduct(updatedProduct);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${selectedProduct!.name} updated successfully!')),
        );
        setState(() {
          selectedProduct = null;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update product')),
        );
      }
    }
  }
}
