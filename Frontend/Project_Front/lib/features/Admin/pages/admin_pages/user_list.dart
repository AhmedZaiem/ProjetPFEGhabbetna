import 'package:authproject/features/Admin/models/user_model.dart';
import 'package:authproject/features/Admin/models/role_model.dart';
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

  List<String> tunisianStates = [
    "Tunis",
    "Ariana",
    "BenArous",
    "Manouba",
    "Nabeul",
    "Zaghouan",
    "Bizerte",
    "Béja",
    "Jendouba",
    "Kef",
    "Siliana",
    "Sousse",
    "Monastir",
    "Mahdia",
    "Sfax",
    "Kairouan",
    "Kasserine",
    "SidiBouzid",
    "Gabès",
    "Medenine",
    "Tataouine",
    "Gafsa",
    "Tozeur",
    "Kebili",
  ];

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
        elevation: 3,
        child: SizedBox(
          height: 110,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30),
              const SizedBox(height: 6),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(UserModel user) {
    final loc = AppLocalizations.of(context)!;

    final firstnameController = TextEditingController(text: user.firstname);
    final lastnameController = TextEditingController(text: user.lastname);
    final cinController = TextEditingController(text: user.cin);
    final usernameController = TextEditingController(text: user.username);
    final emailController = TextEditingController(text: user.email);
    final ageController = TextEditingController(text: user.age.toString());

    String selectedRegion = tunisianStates.contains(user.region)
        ? user.region
        : tunisianStates.first;

    String selectedRole = user.role_name;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: Column(
                children: [
                  Image.asset('assets/images/logoApp.jpeg', height: 60),
                  const SizedBox(height: 10),
                  Text(loc.admin_update),
                ],
              ),

              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: firstnameController,
                        decoration: InputDecoration(
                          labelText: loc.admin_first_name,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: lastnameController,
                        decoration: InputDecoration(
                          labelText: loc.admin_last_name,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: cinController,
                        decoration: InputDecoration(labelText: loc.admin_cin),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: loc.admin_username,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: loc.admin_email),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: ageController,
                        decoration: InputDecoration(labelText: loc.admin_age),
                      ),

                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: selectedRegion,
                        items: tunisianStates
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setStateDialog(() => selectedRegion = v!),
                        decoration: InputDecoration(
                          labelText: loc.admin_region,
                        ),
                      ),

                      const SizedBox(height: 15),

                      FutureBuilder<List<RoleModel>>(
                        future: userService.getRoles(),
                        builder: (context, snapshot) {
                          final roles = snapshot.data ?? [];
                          return DropdownButtonFormField<String>(
                            value: roles.any((r) => r.name == selectedRole)
                                ? selectedRole
                                : null,
                            items: roles
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r.name,
                                    child: Text(r.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setStateDialog(() => selectedRole = v!),
                            decoration: InputDecoration(
                              labelText: loc.admin_role,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.admin_clear),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await userService.updateUser(
                      userId: user.id,
                      firstname: firstnameController.text,
                      lastname: lastnameController.text,
                      cin: cinController.text,
                      username: usernameController.text,
                      email: emailController.text,
                      age: int.parse(ageController.text),
                      roleName: selectedRole,
                      region: selectedRegion,
                    );

                    Navigator.pop(context);

                    _showDialog(
                      result["success"] ? "Success" : "Error",
                      result["message"],
                    );

                    if (result["success"]) _refreshUsers();
                  },
                  child: Text(loc.admin_update),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logoApp.jpeg', height: 60),
            const SizedBox(width: 10),
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
          final totalActiveUsers = users.where((u) => u.isVerified).length;

          return FutureBuilder<List<UserModel>>(
            future: _supervisorsFuture,
            builder: (context, supSnapshot) {
              final totalSupervisors = supSnapshot.data?.length ?? 0;

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
                        const SizedBox(width: 8),
                        _buildCard(
                          t.admin_total_agents,
                          "$totalAgents",
                          Icons.person,
                        ),
                        const SizedBox(width: 8),
                        _buildCard(
                          t.admin_total_supervisors,
                          "$totalSupervisors",
                          Icons.supervisor_account,
                        ),
                        const SizedBox(width: 8),
                        _buildCard(
                          t.admin_total_active_users,
                          "$totalActiveUsers",
                          Icons.verified,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text(t.admin_username)),
                            DataColumn(label: Text(t.admin_first_name)),
                            DataColumn(label: Text(t.admin_last_name)),
                            DataColumn(label: Text(t.admin_email)),
                            DataColumn(label: Text(t.admin_cin)),
                            DataColumn(label: Text(t.admin_age)),
                            DataColumn(label: Text(t.admin_region)),
                            DataColumn(label: Text(t.admin_role_name)),
                            DataColumn(label: Text(t.admin_verified)),
                            DataColumn(label: Text(t.admin_actions)),
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
                                    user.isVerified ? Icons.check : Icons.close,
                                    color: user.isVerified
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 18,
                                          color: Colors.lightBlue,
                                        ),
                                        onPressed: () =>
                                            _showUpdateDialog(user),
                                      ),

                                      const SizedBox(width: 6),

                                      
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: Icon(
                                          user.isBlocked
                                              ? Icons.lock_open
                                              : Icons.lock,
                                          size: 18,
                                          color: user.isBlocked
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        onPressed: () async {
                                          user.isBlocked
                                              ? await userService.unblockUser(
                                                  user.id,
                                                )
                                              : await userService.blockUser(
                                                  user.id,
                                                );

                                          _refreshUsers();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
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
