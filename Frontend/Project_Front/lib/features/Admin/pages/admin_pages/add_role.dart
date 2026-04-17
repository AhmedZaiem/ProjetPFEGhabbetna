import 'package:authproject/features/Admin/models/role_model.dart';
import 'package:authproject/features/Admin/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:authproject/l10n/app_localizations.dart';

class AddRole extends StatefulWidget {
  const AddRole({super.key});

  @override
  State<AddRole> createState() => _AddRoleState();
}

class _AddRoleState extends State<AddRole> {
  final UserService userService = UserService();
  late Future<List<RoleModel>> _rolesFuture;

  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _newRoleController = TextEditingController();

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
    final loc = AppLocalizations.of(context)!;

    if (_roleController.text.trim().isEmpty) return;

    try {
      await userService.createRole(_roleController.text.trim());
      _roleController.clear();
      await _refreshRoles();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.success_role_created)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${loc.error_service}: $e")));
    }
  }

  Future<void> _deleteRole() async {
    final loc = AppLocalizations.of(context)!;

    final roleName = _roleController.text.trim();
    if (roleName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.error_role_empty)));
      return;
    }

    try {
      await userService.deleteRole(roleName);
      _roleController.clear();
      await _refreshRoles();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.success_role_deleted)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${loc.error_service}: $e")));
    }
  }

  Future<void> _modifyRole() async {
    final loc = AppLocalizations.of(context)!;

    final oldName = _roleController.text.trim();
    final newName = _newRoleController.text.trim();

    if (oldName.isEmpty || newName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.error_role_both_required)));
      return;
    }

    try {
      await userService.modifyRole(oldName, newName);
      _roleController.clear();
      _newRoleController.clear();
      await _refreshRoles();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.success_role_modified)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${loc.error_service}: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logoApp.jpeg', height: 80),
            const SizedBox(width: 12),
            Text(loc.admin_roles),
          ],
        ),
      ),
      body: Column(
        children: [
          /// Role Management Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _roleController,
                        decoration: InputDecoration(
                          labelText: loc.admin_role_name,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addRole,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 3, 5, 3),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(loc.admin_add),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _deleteRole,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(loc.admin_delete),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newRoleController,
                        decoration: InputDecoration(
                          labelText: loc.admin_new_role_name,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _modifyRole,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 3, 5, 3),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(loc.admin_modify),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Roles List
          Expanded(
            child: FutureBuilder<List<RoleModel>>(
              future: _rolesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("${loc.error_service}: ${snapshot.error}"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(loc.error_service));
                } else {
                  final roles = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: _refreshRoles,
                    child: ListView.builder(
                      itemCount: roles.length,
                      itemBuilder: (context, index) {
                        final role = roles[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.admin_panel_settings_rounded,
                          ),
                          title: Text(role.name),
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
