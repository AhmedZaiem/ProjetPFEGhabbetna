import 'package:authproject/features/Admin/models/user_model.dart';
import 'package:authproject/features/Admin/services/user_service.dart';
import 'package:flutter/material.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final UserService userService = UserService();
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = userService.fetchUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = userService.fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logoApp.jpeg', height: 80),
            const SizedBox(width: 12),
            const Text("User List"),
          ],
        ),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          } else {
            final users = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Table(
                border: TableBorder.all(color: Colors.white30),
                columnWidths: const {
                  0: FlexColumnWidth(2), // Username
                  1: FlexColumnWidth(3), // Email
                  2: FlexColumnWidth(2), // Role
                  3: FlexColumnWidth(1), // Age
                  4: FlexColumnWidth(1), // Verified
                  5: FlexColumnWidth(2), // Actions
                },
                children: [
                  // Table Header
                  const TableRow(
                    decoration: BoxDecoration(color: Color.fromARGB(255, 212, 198, 198)),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Username",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Email",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Role",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Age",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Verified",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Actions",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // User rows
                  ...users.map(
                    (user) => TableRow(
                      decoration: const BoxDecoration(color: Colors.white),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(user.username),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(user.email),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(user.role_name),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(user.age.toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: user.isVerified
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : const Icon(Icons.cancel, color: Colors.red),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: user.isBlocked
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              child: Text(user.isBlocked ? "Unblock" : "Block"),
                              onPressed: () async {
                                try {
                                  if (user.isBlocked) {
                                    await userService.unblockUser(user.id);
                                  } else {
                                    await userService.blockUser(user.id);
                                  }
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        user.isBlocked
                                            ? "${user.username} unblocked"
                                            : "${user.username} blocked",
                                      ),
                                    ),
                                  );
                                  _refreshUsers();
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Action failed: $e"),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
