import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../../config.dart' as config;
import 'package:authproject/features/Admin/models/role_model.dart';
import 'package:authproject/features/Admin/services/user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:authproject/features/Auth/services/auth_service.dart';

class Create_User extends StatefulWidget {
  const Create_User({super.key});

  @override
  State<Create_User> createState() => _CreateUserState();
}

class _CreateUserState extends State<Create_User> {
  var usernameController = TextEditingController();
  var emailController = TextEditingController();
  var ageController = TextEditingController();

  final storage = FlutterSecureStorage();

  late Future<List<RoleModel>> _rolesFuture;
  final UserService userService = UserService();

  final _formKey = GlobalKey<FormState>();

  final String baseUrl = config.baseUrl;

  String selectedRole = '';
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _rolesFuture = userService.getRoles();
  }

  void CreateUserAcc() async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    int? age = int.tryParse(ageController.text.trim());

    if (username.isEmpty ||
        email.isEmpty ||
        age == null ||
        selectedRole.isEmpty) {
      _showDialog("Error", "Please fill all fields correctly.");
      return;
    }

    final result = await userService.createUser(
      username: username,
      email: email,
      age: age,
      roleName: selectedRole,
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
          TextButton(onPressed: () => context.pop(), child: const Text("OK")),
        ],
      ),
    );
  }

  void logout() async {
    await authService.logout();
    context.replace('/');
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

              SizedBox(height: 20),

              FutureBuilder<List<RoleModel>>(
                future: _rolesFuture,
                builder: (context, snapshot) {
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Select Role'),
                    items: (snapshot.data ?? []).map((role) {
                      return DropdownMenuItem<String>(
                        value: role.name,
                        child: Text(role.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Role is required';
                      }
                      return null;
                    },
                  );
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

              SizedBox(height: 20),

              ElevatedButton(onPressed: logout, child: Text("Logout")),
            ],
          ),
        ),
      ),
    );
  }
}
