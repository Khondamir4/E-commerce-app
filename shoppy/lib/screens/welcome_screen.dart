import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24),
            Text(
              "Find Your \n Perfect Furniture",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                "assets/images/wel.jpg",
                height: 500,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 36),
            OutlinedButton(
              onPressed: () {
                print("pressed");
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                backgroundColor: Colors.black,
              ),
              child: Text(
                "Get Started",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Already have an account? Login",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
