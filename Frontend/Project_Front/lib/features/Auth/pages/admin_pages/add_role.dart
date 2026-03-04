import 'package:authproject/features/Auth/models/role_model.dart';
import 'package:authproject/features/Auth/services/user_service.dart';
import 'package:flutter/material.dart';

class AddRole extends StatefulWidget {
  const AddRole({super.key});

  @override
  State<AddRole> createState() => _AddRoleState();
}

class _AddRoleState extends State<AddRole> {
  final UserService userService = UserService();
  late Future<List<RoleModel>> _rolesFuture;

  final TextEditingController _roleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rolesFuture = userService.getRoles();
  }

  Future<void> _refreshRoles() async {
    setState(() {
      _rolesFuture = userService.getRoles();
    });
  }

  Future<void> _addRole() async {
    if (_roleController.text.trim().isEmpty) return;

    try {
      await userService.createRole(_roleController.text.trim());
      _roleController.clear();
      await _refreshRoles();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Role created successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Role")),
      body: Column(
        children: [
          /// 🔹 Add Role Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _roleController,
                    decoration: const InputDecoration(
                      labelText: "Role Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _addRole, child: const Text("Add")),
              ],
            ),
          ),

          /// 🔹 Roles List
          Expanded(
            child: FutureBuilder<List<RoleModel>>(
              future: _rolesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No roles found'));
                } else {
                  final roles = snapshot.data!;

                  return RefreshIndicator(
                    onRefresh: _refreshRoles,
                    child: ListView.builder(
                      itemCount: roles.length,
                      itemBuilder: (context, index) {
                        final role = roles[index];
                        return ListTile(
                          leading: const Icon(Icons.security),
                          title: Text(role.name),
                          subtitle: Text("ID: ${role.id}"),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
