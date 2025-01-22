import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppy/models/product_model.dart';
import 'package:shoppy/screens/detail_screen.dart';
import 'package:shoppy/screens/list_screen.dart';
import 'package:shoppy/services/provider/product_provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductProvider>(context).products;
    final sortedProducts = (List<Product>.from(products)
          ..sort((a, b) => a.price.compareTo(b.price)))
        .take(3)
        .toList();
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  "assets/images/main.jpg",
                  height: 500,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Popular products",
                            style: TextStyle(fontSize: 24),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ListScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "View all",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 250,
                      child: ListView.separated(
                        separatorBuilder: (context, index) =>
                            SizedBox(width: 12),
                        scrollDirection: Axis.horizontal,
                        itemCount: sortedProducts.length,
                        itemBuilder: (context, index) {
                          final product = sortedProducts[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                  productId: product.id,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    "assets/images/login.webp",
                                    height: 200,
                                    width: 170,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text("\$${product.price}"),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
