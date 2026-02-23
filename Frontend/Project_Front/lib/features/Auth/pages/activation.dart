import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart' as config;

class Activation extends StatefulWidget {
  final String token;
  const Activation({super.key, required this.token});

  @override
  State<Activation> createState() => _ActivationState();
}

class _ActivationState extends State<Activation> {
  var passwordController = TextEditingController();

  final String baseUrl = config.baseUrl;

  void ActiviateAccount() async {
    String password = passwordController.text.trim();

    if (widget.token.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Please fill all fields correctly."),
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
      return;
    }

    var url = Uri.parse("$baseUrl/auth/activate");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'token': widget.token, 'password': password}),
    );
    if (response.statusCode == 200) {
      print("User Activated Successful");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Activation Successful! Please login."),
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
      print("Activation Failed");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Activation Failed! Please try again."),
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
            Text("Activation Page", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
              controller: passwordController,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ActiviateAccount();
              },
              child: const Text('Activiate'),
            ),
          ],
        ),
      ),
    );
  }
}
