import 'package:authproject/features/Admin/models/user_model.dart';
import 'package:authproject/features/Admin/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:authproject/l10n/app_localizations.dart';

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

  Widget _buildCard(String title, String count, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30),
              const SizedBox(height: 8),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logoApp.jpeg', height: 80),
            const SizedBox(width: 12),
            Text(t.admin_users_list),
          ],
        ),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!;
          final totalUsers = users.length;
          final totalAgents = users.where((u) => u.role_name == "Agent").length;
          final totalActiveUsers = users
              .where((u) => u.isVerified == true)
              .length;

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
                          t.admin_total_users,
                          "$totalUsers",
                          Icons.people,
                        ),
                        const SizedBox(width: 10),
                        _buildCard(
                          t.admin_total_agents,
                          "$totalAgents",
                          Icons.person,
                        ),
                        const SizedBox(width: 10),
                        _buildCard(
                          t.admin_total_supervisors,
                          "$totalSupervisors",
                          Icons.supervisor_account,
                        ),
                        const SizedBox(width: 10),
                        _buildCard(
                          t.admin_total_active_users,
                          "$totalActiveUsers",
                          Icons.verified,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    users.isEmpty
                        ? const Text("No users found")
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 6),
                              ],
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth,
                                    ),
                                    child: DataTable(
                                      columnSpacing: 24,
                                      headingRowColor:
                                          MaterialStateProperty.all(
                                            Colors.grey.shade300,
                                          ),
                                      columns: [
                                        DataColumn(
                                          label: Text(t.admin_username),
                                        ),
                                        DataColumn(
                                          label: Text(t.admin_first_name),
                                        ),
                                        DataColumn(
                                          label: Text(t.admin_last_name),
                                        ),
                                        DataColumn(label: Text(t.admin_email)),
                                        DataColumn(label: Text(t.admin_cin)),
                                        DataColumn(label: Text(t.admin_age)),
                                        DataColumn(label: Text(t.admin_region)),
                                        DataColumn(
                                          label: Text(t.admin_role_name),
                                        ),
                                        DataColumn(
                                          label: Text(t.admin_verified),
                                        ),
                                        DataColumn(
                                          label: Text(t.admin_actions),
                                        ),
                                      ],
                                      rows: users.map((user) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(user.username)),
                                            DataCell(Text(user.firstname)),
                                            DataCell(Text(user.lastname)),
                                            DataCell(Text(user.email)),
                                            DataCell(Text(user.cin)),
                                            DataCell(Text(user.age.toString())),
                                            DataCell(Text(user.region)),
                                            DataCell(Text(user.role_name)),

                                            DataCell(
                                              Icon(
                                                user.isVerified
                                                    ? Icons.check
                                                    : Icons.close,
                                                color: user.isVerified
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),

                                            DataCell(
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      user.isBlocked
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
                                                      await userService
                                                          .unblockUser(user.id);
                                                    } else {
                                                      await userService
                                                          .blockUser(user.id);
                                                    }
                                                    _refreshUsers();
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          "Error: $e",
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
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
