import 'package:flutter/material.dart';
import 'package:shoppy/screens/cart_screen.dart';
import 'package:shoppy/screens/detail_screen.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Discover furnitures",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CartScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.shopping_cart_outlined),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.person_outline_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              "assets/images/reg.jpg",
                              height: 200,
                              width: 170,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(
                            "Chair",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text("€45.00"),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("pressed");
                      },
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
                            "Stool",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text("€53.00"),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("pressed");
                      },
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              "assets/images/reg.jpg",
                              height: 200,
                              width: 170,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(
                            "Chair",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text("€45.00"),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("pressed");
                      },
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
                            "Stool",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text("€53.00"),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("pressed");
                      },
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              "assets/images/reg.jpg",
                              height: 200,
                              width: 170,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(
                            "Chair",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text("€45.00"),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("pressed");
                      },
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
                            "Stool",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text("€53.00"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
