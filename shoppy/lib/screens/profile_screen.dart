import 'package:flutter/material.dart';
import 'package:shoppy/widgets/edit_profile_button.dart';
import 'package:shoppy/widgets/logout_button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final String accessToken;
  const ProfileScreen({super.key, required this.accessToken});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> userProfile;

  Future<Map<String, dynamic>> fetchUserProfile(String accessToken) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/profile'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  @override
  void initState() {
    super.initState();
    userProfile = fetchUserProfile(widget.accessToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: FutureBuilder<Map<String, dynamic>>(
              future: userProfile,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  final profileData = snapshot.data!;
                  return Center(
                    child: Column(
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.grey[200],
                              child: Icon(
                                Icons.person,
                                size: 64,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              profileData['username'] ?? 'Username',
                              style: TextStyle(
                                fontSize: 24,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              profileData['email'] ?? 'Email',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            EditProfileButton(
                              onPressed: () {},
                              title: "Edit profile",
                            ),
                          ],
                        ),
                        SizedBox(height: 32),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.shopping_bag_outlined),
                                      SizedBox(width: 20),
                                      Text("Orders"),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.arrow_forward),
                                  ),
                                ],
                              ),
                              Divider(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.phone),
                                      SizedBox(width: 20),
                                      Text("Phone number"),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.arrow_forward),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.document_scanner_outlined),
                                      SizedBox(width: 20),
                                      Text("Privacy and policy"),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.arrow_forward),
                                  ),
                                ],
                              ),
                              Divider(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.file_present),
                                      SizedBox(width: 20),
                                      Text("Documentation"),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.arrow_forward),
                                  ),
                                ],
                              ),
                              Divider(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline_rounded),
                                      SizedBox(width: 20),
                                      Text("About Us"),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.arrow_forward),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        LogoutButton(
                          onPressed: () {},
                          title: "Logout",
                        )
                      ],
                    ),
                  );
                }
                return const Center(
                  child: Text('No profile data available'),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
