import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Welcome extends StatefulWidget {
  final String email;

  const Welcome({super.key, required this.email});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  Map<String, dynamic>? data;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    try {
      var encodedEmail = Uri.encodeComponent(widget.email);
      var url = Uri.parse("http://192.168.1.9:8000/auth/User/$encodedEmail");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
        });
      } else {
        setState(() {
          error = "Failed to load user data";
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Welcome Page", style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          if (data != null) ...[
            Text(
              "Username: ${data!['username']}",
              style: TextStyle(fontSize: 18),
            ),
            Text("Email: ${data!['email']}", style: TextStyle(fontSize: 18)),
            Text("Age: ${data!['age']}", style: TextStyle(fontSize: 18)),
          ] else if (error != null) ...[
            Text(
              "Error: $error",
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ] else ...[
            CircularProgressIndicator(),
          ],
        ],
      ),
    );
  }
}
