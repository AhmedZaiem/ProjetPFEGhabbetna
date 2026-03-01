import 'package:authproject/features/Auth/models/user_model.dart';
import 'package:authproject/features/Auth/services/user_service.dart';
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
      appBar: AppBar(title: const Text("User List")),
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
            return Column(
              children: [
                // Header row
                Container(
                  color: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Username",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Email",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Role",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "Age",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "Verified",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Actions",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                // User list
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text(user.username)),
                              Expanded(flex: 3, child: Text(user.email)),
                              Expanded(flex: 2, child: Text(user.role)),
                              Expanded(
                                flex: 1,
                                child: Text(user.age.toString()),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: user.isVerified
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                      : const Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                        ),
                                ),
                              ),
                              // Actions button
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: user.isBlocked
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    child: Text(
                                      user.isBlocked ? "Unblock" : "Block",
                                    ),
                                    onPressed: () async {
                                      try {
                                        if (user.isBlocked) {
                                          await userService.unblockUser(
                                            user.id,
                                          );
                                        } else {
                                          await userService.blockUser(user.id);
                                        }
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
