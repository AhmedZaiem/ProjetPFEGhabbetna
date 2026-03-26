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
      final allForests = await forestService.getFreeForests();
      print('Unassigned forests: ${allForests.map((f) => f.name).toList()}');

      final funassignedSupervisor = await userService.getSupervisors();
      print(
        'Unassigned supervisors: ${funassignedSupervisor.map((u) => u.username).toList()}',
      );

      setState(() {
        forests = allForests;
        unassignedSupervisor = funassignedSupervisor;

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
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                      label: (u) => u.username,
                      onChanged: (u) =>
                          setState(() => selectedUserForForest = u),
                    ),

                    const SizedBox(height: 12),

                    CustomDropdown(
                      value: selectedForest,
                      hint: "Select Forest",
                      items: forests,
                      label: (p) => p.name,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
