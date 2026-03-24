import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:authproject/features/Admin/models/role_model.dart';
import 'package:authproject/features/Admin/services/user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

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
  String selectedRole = '';

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
        title: Text(title, style: const TextStyle(color: Color(0xFF1B5E20))),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 350,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logoApp.jpeg',
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                      const SizedBox(height: 20),

                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                      const SizedBox(height: 20),

                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Age',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                      const SizedBox(height: 20),

                      FutureBuilder<List<RoleModel>>(
                        future: _rolesFuture,
                        builder: (context, snapshot) {
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Select Role',
                              prefixIcon: const Icon(
                                Icons.admin_panel_settings,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              CreateUserAcc();
                            }
                          },
                          child: const Text('Create Account'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
