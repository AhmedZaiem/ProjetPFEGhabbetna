import 'package:flutter/material.dart';
import 'package:authproject/features/Admin/models/user_model.dart';
import 'package:authproject/features/Admin/models/forest_model.dart';
import 'package:authproject/features/Admin/services/forest_service.dart';
import 'package:authproject/features/Admin/services/user_service.dart';
import 'package:authproject/features/Admin/ui_components/assignment_card.dart';
import 'package:authproject/features/Admin/ui_components/custom_dropdown.dart';

class Assign extends StatefulWidget {
  const Assign({super.key});

  @override
  State<Assign> createState() => _AssignState();
}

class _AssignState extends State<Assign> {
  final ForestService forestService = ForestService();
  final UserService userService = UserService();

  List<Forest> forests = [];
  List<UserModel> unassignedSupervisor = [];

  Map<int, UserModel> assignedSupervisors = {}; // supervisorId -> UserModel
  Map<int, String> supervisorForestMap = {}; // supervisorId -> forestName

  Forest? selectedForest;
  UserModel? selectedUserForForest;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    try {
      final allForests = await forestService.getForests();
      final unassigned = await userService.getSupervisors();

      // Map assigned supervisors to forests
      assignedSupervisors.clear();
      supervisorForestMap.clear();
      final allUsers = await userService.fetchUsers();
      for (var f in allForests) {
        if (f.supervisorId != null) {
          supervisorForestMap[f.supervisorId!] = f.name;
          final u = allUsers.firstWhere(
            (user) => user.id == f.supervisorId,
            orElse: () => UserModel(
              id: f.supervisorId!,
              username: "Unknown",
              firstname: "",
              lastname: "",
              email: "",
              region: "",
              role_name: "supervisor",
              age: 0,
              cin: "",
              isVerified: false,
              isBlocked: false,
            ),
          );
          assignedSupervisors[f.supervisorId!] = u;
        }
      }

      setState(() {
        forests = allForests.where((f) => f.supervisorId == null).toList();
        unassignedSupervisor = unassigned;
        selectedForest = null;
        selectedUserForForest = null;
        loading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() => loading = false);
    }
  }

  Future<void> assignSupervisor() async {
    if (selectedForest == null || selectedUserForForest == null) return;

    try {
      await forestService.assignSupervisor(
        selectedForest!.id,
        selectedUserForForest!.id,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Supervisor assigned successfully")),
      );
      await loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logoApp.jpeg', height: 80),
            const SizedBox(width: 12),
            const Text("Assign Supervisor"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                AssignmentCard(
                  title: "Assign Supervisor to Forest",
                  children: [
                    CustomDropdown(
                      value: selectedUserForForest,
                      hint: "Select Supervisor",
                      items: unassignedSupervisor,
                      label: (u) => "${u.username} - ${u.region}",
                      onChanged: (u) =>
                          setState(() => selectedUserForForest = u),
                    ),
                    const SizedBox(height: 12),
                    CustomDropdown(
                      value: selectedForest,
                      hint: "Select Forest",
                      items: forests,
                      label: (p) => "${p.name} - ${p.region}",
                      onChanged: (p) => setState(() => selectedForest = p),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            (selectedUserForForest != null &&
                                selectedForest != null)
                            ? assignSupervisor
                            : null,
                        icon: const Icon(Icons.supervisor_account),
                        label: const Text("Assign Supervisor"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Display assigned supervisors
                AssignmentCard(
                  title: "Assigned Supervisors",
                  children: assignedSupervisors.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "No supervisors assigned yet.",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ]
                      : assignedSupervisors.entries.map((e) {
                          final u = e.value;
                          final fName =
                              supervisorForestMap[e.key] ?? "Unknown Forest";
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.green,
                                      child: Text(
                                        u.username[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Username: ${u.username}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "First Name: ${u.firstname}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Last Name: ${u.lastname}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Region: ${u.region}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.park,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Forest: $fName",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
