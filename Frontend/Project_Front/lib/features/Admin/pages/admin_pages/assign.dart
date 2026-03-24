import 'package:flutter/material.dart';

import 'package:authproject/features/Admin/models/user_model.dart';
import 'package:authproject/features/Admin/models/forest_model.dart';
import 'package:authproject/features/Admin/models/parcelle_model.dart';
import 'package:authproject/features/Admin/services/forest_service.dart';
import 'package:authproject/features/Admin/services/parcelle_service.dart';
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
  final ParcelService parcelService = ParcelService();
  final UserService userService = UserService();

  List<Forest> forests = [];
  List<Parcel> parcels = [];
  List<UserModel> unassignedSupervisor = [];
  List<UserModel> unassignedAgents = [];

  Forest? selectedForest;
  Parcel? selectedParcel;
  UserModel? selectedUserForForest;
  UserModel? selectedUserForParcel;

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

      final allParcels = await parcelService.getFreeParcels();
      print('Unassigned parcels: ${allParcels.map((p) => p.name).toList()}');

      final funassignedSupervisor = await userService.getSupervisors();
      print(
        'Unassigned supervisors: ${funassignedSupervisor.map((u) => u.username).toList()}',
      );

      final fetchedUnassignedAgents = await userService.getUnassignedAgents();
      print(
        'Unassigned agents: ${fetchedUnassignedAgents.map((u) => u.username).toList()}',
      );

      setState(() {
        forests = allForests;
        parcels = allParcels;
        unassignedSupervisor = funassignedSupervisor;
        unassignedAgents = fetchedUnassignedAgents;

        selectedForest = null;
        selectedParcel = null;
        selectedUserForForest = null;
        selectedUserForParcel = null;

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

  Future<void> assignAgent() async {
    if (selectedParcel == null || selectedUserForParcel == null) return;

    try {
      await parcelService.assignAgent(
        selectedParcel!.id,
        selectedUserForParcel!.id,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agent assigned successfully")),
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
            const Text("Assign User"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Assign Agent
                Expanded(
                  child: AssignmentCard(
                    title: "Assign Agent to Parcelle",
                    children: [
                      CustomDropdown(
                        value: selectedUserForParcel,
                        hint: "Select Agent",
                        items: unassignedAgents,
                        label: (u) => u.username,
                        onChanged: (u) =>
                            setState(() => selectedUserForParcel = u),
                      ),
                      const SizedBox(height: 12),
                      CustomDropdown(
                        value: selectedParcel,
                        hint: "Select Parcelle",
                        items: parcels,
                        label: (p) => p.name,
                        onChanged: (p) => setState(() => selectedParcel = p),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              (selectedUserForParcel != null &&
                                  selectedParcel != null)
                              ? assignAgent
                              : null,
                          icon: const Icon(Icons.assignment_turned_in),
                          label: const Text("Assign Agent"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
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
                ),

                const SizedBox(width: 24), // spacing between the two forms
                /// Assign Supervisor
                Expanded(
                  child: AssignmentCard(
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
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
