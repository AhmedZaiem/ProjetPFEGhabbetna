import 'package:flutter/material.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;
  String? error;

  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final result = await authService.getCurrentUser();
    if (result['success']) {
      setState(() => userData = result['data']);
    } else {
      setState(() => error = result['message']);
    }
  }

  void logout() async {
    await authService.logout();
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logoApp.jpeg', height: 80),
            const SizedBox(width: 12),
            const Text("Profile"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: userData != null
            ? Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, size: 40, color: Colors.blue),
                      ),
                      SizedBox(height: 24),

                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("First Name: ${userData!['firstname']}"),
                              SizedBox(height: 16),
                              Text("Last Name: ${userData!['lastname']}"),
                              SizedBox(height: 16),
                              Text("Cin: ${userData!['cin']}"),
                              SizedBox(height: 16),
                              Text("Username: ${userData!['username']}"),
                              SizedBox(height: 16),
                              Text("Email: ${userData!['email']}"),
                              SizedBox(height: 16),
                              Text("Age: ${userData!['age']}"),
                              SizedBox(height: 16),
                              Text("Region: ${userData!['region']}"),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: logout,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            textStyle: TextStyle(fontSize: 14),
                          ),
                          child: Text("Logout"),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
