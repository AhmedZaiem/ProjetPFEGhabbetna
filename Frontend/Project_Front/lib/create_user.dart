import 'package:flutter/material.dart';
import 'package:authproject/login.dart';
import 'package:http/http.dart' as http;
import 'config.dart' as config;

import 'dart:convert';

class Create_User extends StatefulWidget {
  const Create_User({super.key});

  @override
  State<Create_User> createState() => _CreateUserState();
}

class _CreateUserState extends State<Create_User> {
  var usernameController = TextEditingController();
  var emailController = TextEditingController();
  var ageController = TextEditingController();
  String selectedRole = "agent";

  final String baseUrl = config.baseUrl;

  void CreateUserAcc() async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    int? age = int.tryParse(ageController.text.trim());

    if (username.isEmpty ||
        email.isEmpty ||
        age == null ||
        selectedRole.isEmpty) {
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

    var url = Uri.parse("$baseUrl/auth/register");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': username,
        'email': email,
        'age': age,
        'role': selectedRole,
      }),
    );
    if (response.statusCode == 200) {
      print("User Created Successful");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Registration Successful! Please login."),
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
      print("Registration Failed");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Registration Failed! Please try again."),
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
            Text("Create Account Page", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'Username'),
              controller: usernameController,
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
              controller: emailController,
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
              controller: ageController,
            ),
            SizedBox(height: 40),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(
                labelText: "Role",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "agent", child: Text("Agent")),

                DropdownMenuItem(
                  value: "superviseur",
                  child: Text("Superviseur"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                CreateUserAcc();
              },
              child: Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
