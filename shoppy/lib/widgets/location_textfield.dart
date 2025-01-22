import 'package:flutter/material.dart';

class LocationTextfield extends StatelessWidget {
  final String hintText;
  final Icon? prefixIcon;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  const LocationTextfield(
      {super.key,
      required this.hintText,
      this.prefixIcon,
      this.keyboardType,
      this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        prefixIconColor: Colors.grey,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(width: 0.5, color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(width: 0.5, color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(width: 0.5, color: Colors.white),
        ),
      ),
    );
  }
}
