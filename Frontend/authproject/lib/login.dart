import 'package:flutter/material.dart';
import 'package:authproject/register.dart';
import 'package:authproject/welcome.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _LoginState();
}

class _LoginState extends State<login> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  void LoginUser() async {
    var url = Uri.parse("http://192.168.1.9:8000/auth/login");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );
    if (response.statusCode == 200) {
      print("Login Successful");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Welcome(email: emailController.text),
        ),
      );
    } else {
      print("Login Failed");
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
