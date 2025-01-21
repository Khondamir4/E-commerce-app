import 'package:flutter/material.dart';

class EditProfileButton extends StatelessWidget {
  final void Function() onPressed;
  final String title;
  const EditProfileButton({
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
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 20,
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
