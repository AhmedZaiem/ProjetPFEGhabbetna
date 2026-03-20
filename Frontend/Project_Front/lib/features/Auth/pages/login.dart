import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../config.dart' as config;
import 'package:authproject/features/Auth/services/auth_service.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _LoginState();
}

class _LoginState extends State<login> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final storage = FlutterSecureStorage();
  final String baseUrl = config.baseUrl;
  final AuthService authService = AuthService();

  void loginUser() async {
    final result = await authService.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (result['success']) {
      final accessToken = result['data']['access_token'];
      final decoded = JwtDecoder.decode(accessToken);
      int roleId = decoded['role_id'];

      if (roleId == 1) {
        context.replace("/admin_dashboard");
      } else if (roleId == 2) {
        context.replace("/supervisor_home");
      } else {
        context.replace("/welcome");
      }
    } else {
      _showDialog("Error", result['message']);
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text("OK")),
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
              Text("Login Page", style: TextStyle(fontSize: 24)),

              TextFormField(
                decoration: InputDecoration(labelText: "Email"),
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
                    loginUser();
                  }
                },
                child: const Text('Login'),
              ),

              SizedBox(height: 10),

              SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  context.push('/forgot_password');
                },
                child: const Text('Forget Password ?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
