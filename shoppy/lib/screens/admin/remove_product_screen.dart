// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shoppy/services/provider/product_provider.dart';
import 'package:shoppy/services/provider/userdata_provider.dart';

class RemoveProductScreen extends StatelessWidget {
  const RemoveProductScreen({super.key});

  Future<void> removeProduct(BuildContext context, int productId) async {
    final token = Provider.of<UserData>(context, listen: false).accessToken;

    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/products/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        Provider.of<ProductProvider>(context, listen: false)
            .removeProduct(productId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product deleted successfully')),
        );
      } else {
        final body = json.decode(response.body);
        throw Exception(body['detail'] ?? 'Failed to delete product');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(title: Text('Remove Products')),
      body: SafeArea(
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text('${product.price} USD'),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => removeProduct(context, product.id),
              ),
            );
          },
        ),
      ),
    );
  }
}
