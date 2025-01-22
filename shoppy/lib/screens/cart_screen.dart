import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppy/models/product_model.dart';
import 'package:shoppy/screens/checkout_screen.dart';
import 'package:shoppy/services/provider/cart_provider.dart';
import 'package:shoppy/widgets/checkout_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Cart",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            //_buildHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: cartItems.isEmpty
                  ? const Center(
                      child: Text(
                        "Your cart is empty!",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : _buildCartItems(cartItems, cartProvider),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: CheckoutButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(),
                    ),
                  );
                },
                title: "Checkout",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems(List<Product> cartItems, CartProvider cartProvider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final product = cartItems[index];
        return _buildCartItem(product, cartProvider);
      },
    );
  }

  Widget _buildCartItem(Product product, CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              "assets/images/reg.jpg",
              height: 150,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              cartProvider.removeFromCart(product);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
