import 'package:flutter/material.dart';
import 'package:shoppy/models/product_model.dart';
import 'package:shoppy/screens/detail_screen.dart';
import 'package:shoppy/screens/list_screen.dart';

class MainScreen extends StatelessWidget {
  final List<Product> products;

  const MainScreen({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
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
                                  builder: (context) => ListScreen(
                                    products: products,
                                  ),
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
                      SizedBox(height: 8),
                      SizedBox(
                        height: 250,
                        child: ListView.separated(
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 8),
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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
