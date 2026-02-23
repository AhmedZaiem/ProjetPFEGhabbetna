import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config.dart' as config;
import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  var emailController = TextEditingController();

  final String baseUrl = config.baseUrl;

  void ForgetPassword() async {
    if (emailController.text.isEmpty) {
      // Quick validation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Please enter your email."),
          actions: [
            TextButton(onPressed: () => context.pop(), child: Text("OK")),
          ],
        ),
      );
      return;
    }

    var url = Uri.parse("$baseUrl/auth/forgot-password");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': emailController.text}),
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Password reset email sent successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                  context.replace('/');
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
            content: Text("Forget Password Failed! Please check your email."),
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
            Text('Forgot-Password Page', style: TextStyle(fontSize: 24)),
            TextField(
              decoration: InputDecoration(labelText: "Email"),
              controller: emailController,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ForgetPassword();
              },
              child: const Text("Send Email"),
            ),
          ],
        ),
      ),
    );
  }
}
