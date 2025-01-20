import 'package:flutter/material.dart';
import 'package:shoppy/screens/login_screen.dart';

class LoginLink extends StatelessWidget {
  const LoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      },
      child: Text.rich(
        TextSpan(
          text: "Already have an account? ",
          style: TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: "Login",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
