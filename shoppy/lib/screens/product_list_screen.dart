import 'package:flutter/material.dart';
import 'package:shoppy/models/product_model.dart';
import 'package:shoppy/screens/product_detail_screen.dart';

class ProductListScreen extends StatelessWidget {
  final List<Product> products; // Assuming you have a list of products already

  const ProductListScreen({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product List')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              // Navigate to product detail screen with productId
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailScreen(productId: product.id),
                ),
              );
            },
            child: Card(
              child: ListTile(
                title: Text(product.name),
                subtitle: Text("\$${product.price}"),
                leading: Icon(Icons.shop),
              ),
            ),
          );
        },
      ),
    );
  }
}
