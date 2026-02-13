import 'package:authproject/welcome.dart';
import 'package:flutter/material.dart';
import 'package:authproject/register.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart' as config;

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _LoginState();
}

class _LoginState extends State<login> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  final storage = FlutterSecureStorage();
  final String baseUrl = config.baseUrl;

  void LoginUser() async {
    var url = Uri.parse("$baseUrl/auth/login");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String accessToken = data['access_token'];
      await storage.write(key: "access_token", value: accessToken);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Welcome()),
      );
    } else {
      print("Login Failed");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Login Failed! Please check your credentials."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
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
            Text("Login Page", style: TextStyle(fontSize: 24)),
            TextField(
              decoration: InputDecoration(labelText: "Email"),
              controller: emailController,
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
                LoginUser();
              },
              child: const Text('Login'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Register()),
                );
              },
              child: const Text('Don t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}
