import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:authproject/login.dart';

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: data != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(Icons.person, size: 40, color: Colors.blue),
                    ),
                    SizedBox(height: 20),

                    Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 20),

                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Username: ${data!['username']}"),
                            SizedBox(height: 8),
                            Text("Email: ${data!['email']}"),
                            SizedBox(height: 8),
                            Text("Age: ${data!['age']}"),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => login()),
                        );
                      },
                      child: Text("Logout"),
                    ),
                  ],
                )
              : error != null
              ? Text(error!, style: TextStyle(color: Colors.red))
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}
