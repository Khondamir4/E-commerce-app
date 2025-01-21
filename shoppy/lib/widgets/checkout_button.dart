import 'package:flutter/material.dart';

class CheckoutButton extends StatelessWidget {
  final void Function() onPressed;
  final String title;
  const CheckoutButton({
    super.key,
    required this.onPressed,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 140,
        ),
        backgroundColor: Colors.black,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
