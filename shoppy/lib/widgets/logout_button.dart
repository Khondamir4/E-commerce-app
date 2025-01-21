import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  final void Function() onPressed;
  final String title;
  const LogoutButton({
    super.key,
    required this.onPressed,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: Colors.red.shade100,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 20,
        ),
        backgroundColor: Colors.red[100],
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.red[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
