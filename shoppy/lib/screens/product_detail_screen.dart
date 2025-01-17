import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ProductDetailScreenState createState() => ProductDetailScreenState();
}

class ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isLoading = true;
  late Map<String, dynamic> product;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProductDetail();
  }

  Future<void> fetchProductDetail() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/products/${widget.productId}'),
    );

    if (!mounted) return; // Make sure widget is still mounted before updating

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      product = jsonDecode(
          response.body); // Assuming response contains product data as a map
      setState(() {});
    } else {
      setState(() {
        errorMessage = 'Failed to load product details';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Product Details")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text("Price: \$${product['price']}"),
                      SizedBox(height: 10),
                      Text("Description: ${product['description']}"),
                      SizedBox(height: 10),
                      Text("Quantity: ${product['quantity']}"),
                    ],
                  ),
                ),
    );
  }
}
