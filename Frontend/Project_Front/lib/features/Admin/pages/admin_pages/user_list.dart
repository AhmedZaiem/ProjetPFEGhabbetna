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
  late Future<List<UserModel>> _supervisorsFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = userService.fetchUsers();
    _supervisorsFuture = userService.getSupervisors();
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = userService.fetchUsers();
      _supervisorsFuture = userService.getSupervisors();
    });
  }

  Widget _buildCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: 140,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              FittedBox(
                child: Text(
                  count,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
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
          }

          final users = snapshot.data ?? [];
          final totalUsers = users.length;
          final totalAgents = users.where((u) => u.role_name == "Agent").length;

          return FutureBuilder<List<UserModel>>(
            future: _supervisorsFuture,
            builder: (context, supSnapshot) {
              final totalSupervisors = supSnapshot.hasData
                  ? supSnapshot.data!.length
                  : 0;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildCard(
                          "Total Users",
                          totalUsers.toString(),
                          Icons.people,
                          const Color.fromARGB(255, 0, 0, 0),
                        ),
                        const SizedBox(width: 12),
                        _buildCard(
                          "Total Agents",
                          totalAgents.toString(),
                          Icons.person_outline,
                          const Color.fromARGB(255, 0, 0, 0),
                        ),
                        const SizedBox(width: 12),
                        _buildCard(
                          "Total Supervisors",
                          totalSupervisors.toString(),
                          Icons.supervised_user_circle,
                          const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    users.isEmpty
                        ? const Center(child: Text('No users found'))
                        : Table(
                            border: TableBorder.all(color: Colors.white30),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(3),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(1),
                              4: FlexColumnWidth(1),
                              5: FlexColumnWidth(2),
                            },
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 212, 198, 198),
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Username",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Email",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Role",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Age",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Verified",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Actions",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ...users.map(
                                (user) => TableRow(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(user.username),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(user.email),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(user.role_name),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(user.age.toString()),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
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
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Center(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: user.isBlocked
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          child: Text(
                                            user.isBlocked
                                                ? "Unblock"
                                                : "Block",
                                          ),
                                          onPressed: () async {
                                            try {
                                              if (user.isBlocked) {
                                                await userService.unblockUser(
                                                  user.id,
                                                );
                                              } else {
                                                await userService.blockUser(
                                                  user.id,
                                                );
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
                                                  content: Text(
                                                    "Action failed: $e",
                                                  ),
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
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
