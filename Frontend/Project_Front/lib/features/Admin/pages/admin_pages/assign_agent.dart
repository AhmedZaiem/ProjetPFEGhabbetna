import 'package:flutter/material.dart';
import 'package:authproject/features/Admin/models/user_model.dart';
import 'package:authproject/features/Admin/models/parcelle_model.dart';
import 'package:authproject/features/Admin/services/parcelle_service.dart';
import 'package:authproject/features/Admin/services/user_service.dart';
import 'package:authproject/features/Admin/ui_components/assignment_card.dart';
import 'package:authproject/features/Admin/ui_components/custom_dropdown.dart';

class AssignAgent extends StatefulWidget {
  const AssignAgent({super.key});

  @override
  State<AssignAgent> createState() => _AssignAgentState();
}

class _AssignAgentState extends State<AssignAgent> {
  final ParcelService parcelService = ParcelService();
  final UserService userService = UserService();

  List<Parcel> parcels = [];
  List<UserModel> unassignedAgents = [];

  Parcel? selectedParcel;
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
      final allParcels = await parcelService.getFreeParcels();
      print('Unassigned parcels: ${allParcels.map((p) => p.name).toList()}');

      final fetchedUnassignedAgents = await userService.getUnassignedAgents();
      print(
        'Unassigned agents: ${fetchedUnassignedAgents.map((u) => u.username).toList()}',
      );

      setState(() {
        parcels = allParcels;
        unassignedAgents = fetchedUnassignedAgents;

        selectedParcel = null;
        selectedUserForParcel = null;

        loading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() => loading = false);
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
            const Text("Assign Agent"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),
            child: Column(
              children: [
                AssignmentCard(
                  title: "Assign Agent to Parcelle",
                  children: [
                    CustomDropdown(
                      value: selectedUserForParcel,
                      hint: "Select Agent",
                      items: unassignedAgents,
                      label: (u) => "${u.username} - ${u.region}",
                      onChanged: (u) =>
                          setState(() => selectedUserForParcel = u),
                    ),

                    const SizedBox(height: 12),

                    CustomDropdown(
                      value: selectedParcel,
                      hint: "Select Parcelle",
                      items: parcels,
                      label: (p) => "${p.name} - ${p.region}",
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

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
