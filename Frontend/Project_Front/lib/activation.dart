import 'dart:convert';
import 'package:authproject/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart' as config;

class Activation extends StatefulWidget {
  const Activation({super.key});

  @override
  State<Activation> createState() => _ActivationState();
}

class _ActivationState extends State<Activation> {
  var activationTokenController = TextEditingController();
  var passwordController = TextEditingController();

  final String baseUrl = config.baseUrl;

  void ActiviateAccount() async {
    String token = activationTokenController.text.trim();
    String password = passwordController.text.trim();

    if (token.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Please fill all fields correctly."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
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
      body: jsonEncode({'token': token, 'password': password}),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => login()),
                  );
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
                  Navigator.of(context).pop();
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
            TextField(
              decoration: InputDecoration(labelText: "token activation"),
              controller: activationTokenController,
            ),
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
