import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart' as config;

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

  final _formKey = GlobalKey<FormState>();

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
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Please fill all fields correctly."),
          actions: [
            TextButton(onPressed: () => context.pop(), child: const Text("OK")),
          ],
        ),
      );
      return;
    }

    try {
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

      final data = jsonDecode(response.body);
      final message =
          (data['message'] as String?) ??
          "Registration failed. Please check your input.";

      final bool success;
      if (data.containsKey('success')) {
        success = data['success'] == true;
      } else {
        success =
            message.toLowerCase().contains("created") ||
            message.toLowerCase().contains("success");
      }

      if (success) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Success"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                  context.replace('/');
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("An error occurred: $e"),
          actions: [
            TextButton(onPressed: () => context.pop(), child: const Text("OK")),
          ],
        ),
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
              Text("Create Account Page", style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),

            
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                controller: usernameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username is required';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                    return 'Only letters and numbers allowed';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Enter valid email';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

  
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                controller: ageController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Age is required';
                  }
                  final age = int.tryParse(value);
                  if (age == null) {
                    return 'Enter valid number';
                  }
                  if (age <= 18) {
                    return 'Age must be greater than 18';
                  }
                  return null;
                },
              ),

              SizedBox(height: 40),

            
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
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
                  if (_formKey.currentState!.validate()) {
                    CreateUserAcc();
                  }
                },
                child: Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
