import 'package:flutter/material.dart';
import 'package:shoppy/screens/list_screen.dart';
import 'package:shoppy/widgets/checkout_button.dart';
import 'package:shoppy/widgets/location_textfield.dart';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  void showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListScreen(),
          ),
        );
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Successful payment"),
      content: const Text(
        "Thank you for purchasing furniture from our shop.",
      ),
      actions: [okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  LocationTextfield(
                    hintText: "Address",
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  LocationTextfield(
                    hintText: "Name",
                    prefixIcon: const Icon(Icons.person),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  LocationTextfield(
                    hintText: "Phone number",
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      } else if (value.length < 10 || value.length > 15) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  LocationTextfield(
                    hintText: "Card number",
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.credit_card),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your card number';
                      } else if (value.length != 16) {
                        return 'Card number must be 16 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  LocationTextfield(
                    hintText: "Expiry Date (MM/YY)",
                    keyboardType: TextInputType.datetime,
                    prefixIcon: const Icon(Icons.date_range_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the expiry date';
                      } else if (!RegExp(r"^(0[1-9]|1[0-2])\/?([0-9]{2})$")
                          .hasMatch(value)) {
                        return 'Enter a valid expiry date (MM/YY)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  LocationTextfield(
                    hintText: "CVV",
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.credit_score_sharp),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the CVV';
                      } else if (value.length != 3) {
                        return 'CVV must be 3 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 200),
                  CheckoutButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Processing Payment...'),
                          ),
                        );
                        showAlertDialog(context);
                      }
                    },
                    title: "Pay",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
