import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  AdminDashboardScreen({super.key});

  // This is an example list of items that the admin could interact with
  final List<String> menuItems = [
    "Manage Products",
    "View Orders",
    "View Customers",
    "Site Settings",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Handle logout here
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            // Dashboard title
            Text(
              'Admin Actions',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            SizedBox(height: 20),
            // Menu items for navigation
            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(menuItems[index]),
                    onTap: () {
                      // Navigate to appropriate admin screen based on menu item
                      switch (index) {
                        case 0:
                          Navigator.pushNamed(context, '/manage_products');
                          break;
                        case 1:
                          Navigator.pushNamed(context, '/view_orders');
                          break;
                        case 2:
                          Navigator.pushNamed(context, '/view_customers');
                          break;
                        case 3:
                          Navigator.pushNamed(context, '/site_settings');
                          break;
                        default:
                          break;
                      }
                    },
                    trailing: Icon(Icons.arrow_forward_ios),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
