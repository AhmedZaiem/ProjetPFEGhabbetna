import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config.dart' as config;
import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetPassword extends StatefulWidget {
  final String token;

  const ResetPassword({super.key, required this.token});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  var PasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final String baseUrl = config.baseUrl;

  void ResetPassword() async {
    if (PasswordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Please enter your new password."),
          actions: [
            TextButton(onPressed: () => context.pop(), child: Text("OK")),
          ],
        ),
      );
      return;
    }

    var url = Uri.parse("$baseUrl/auth/reset-password");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'token': widget.token,
        'new_password': PasswordController.text,
      }),
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Password Updated successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop(); // Close the dialog
                  context.replace('/'); // Navigate to login page
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Password Reset Failed."),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Reset-Password Page', style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),

              /// NEW PASSWORD
              TextFormField(
                decoration: InputDecoration(labelText: "New Password"),
                obscureText: true,
                controller: PasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              /// BUTTON
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ResetPassword();
                  }
                },
                child: const Text("Update Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
