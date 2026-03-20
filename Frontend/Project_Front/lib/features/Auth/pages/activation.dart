import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart' as config;
import 'package:authproject/features/Auth/services/auth_service.dart';

class Activation extends StatefulWidget {
  final String token;
  const Activation({super.key, required this.token});

  @override
  State<Activation> createState() => _ActivationState();
}

class _ActivationState extends State<Activation> {
  var passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final String baseUrl = config.baseUrl;
  final AuthService authService = AuthService();

  void activateAccount() async {
    final result = await authService.activateAccount(
      token: widget.token,
      password: passwordController.text.trim(),
    );

    _showDialog(result['success'] ? "Success" : "Error", result['message']);
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              if (title == "Success") context.replace('/');
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
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
              Text("Activation Page", style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),

              TextFormField(
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                controller: passwordController,
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

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    activateAccount();
                  }
                },
                child: const Text('Activate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
