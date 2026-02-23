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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Reset-Password Page', style: TextStyle(fontSize: 24)),
            TextField(
              decoration: InputDecoration(labelText: "New Password"),
              controller: PasswordController,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ResetPassword();
              },
              child: const Text("Update Password"),
            ),
          ],
        ),
      ),
    );
  }
}
