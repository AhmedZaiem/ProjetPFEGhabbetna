import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config.dart' as config;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:authproject/features/Auth/services/auth_service.dart';

class ResetPassword extends StatefulWidget {
  final String token;

  const ResetPassword({super.key, required this.token});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  var passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final String baseUrl = config.baseUrl;
  final AuthService authService = AuthService();

  void resetPassword() async {
    final result = await authService.resetPassword(
      token: widget.token,
      newPassword: passwordController.text.trim(),
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
              Text('Reset-Password Page', style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),

              /// NEW PASSWORD
              TextFormField(
                decoration: InputDecoration(labelText: "New Password"),
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

              /// BUTTON
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    resetPassword();
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
