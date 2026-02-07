import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:authproject/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  Map<String, dynamic>? data;
  String? error;

  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    try {
      String? token = await storage.read(key: "access_token");
      if (token == null) {
        setState(() {
          error = "No access token found. Please log in.";
        });
        return;
      }
      var url = Uri.parse("http://192.168.1.5:8000/auth/me");
      var response = await http.get(
        url,
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
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
                      onPressed: () async {
                        await storage.delete(key: "access_token");
                        Navigator.pushReplacement(
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
