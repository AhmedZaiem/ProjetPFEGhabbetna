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

  Map<int, UserModel> assignedAgents = {}; // agentId -> UserModel
  Map<int, String> agentParcelMap = {}; // agentId -> parcel name

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
      final allParcels = await parcelService.getParcels();
      final unassigned = await userService.getUnassignedAgents();

      // Map assigned agents to parcels
      assignedAgents.clear();
      agentParcelMap.clear();
      final allUsers = await userService
          .fetchUsers(); // fetch all users for mapping
      for (var p in allParcels) {
        if (p.agentId != null) {
          agentParcelMap[p.agentId!] = p.name;
          final u = allUsers.firstWhere(
            (user) => user.id == p.agentId,
            orElse: () => UserModel(
              id: p.agentId!,
              username: "Unknown",
              firstname: "",
              lastname: "",
              email: "",
              region: "",
              role_name: "agent",
              age: 0,
              cin: "",
              isVerified: false,
              isBlocked: false,
            ),
          );
          assignedAgents[p.agentId!] = u;
        }
      }
      setState(() {
        parcels = allParcels.where((p) => p.agentId == null).toList();
        unassignedAgents = unassigned;
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
    if (loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
            constraints: const BoxConstraints(maxWidth: 700),
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

                AssignmentCard(
                  title: "Assigned Agents",
                  children: assignedAgents.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "No agents assigned yet.",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ]
                      : assignedAgents.entries.map((e) {
                          final u = e.value;
                          final pName =
                              agentParcelMap[e.key] ?? "Unknown Parcelle";
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
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
                                      backgroundColor: Colors.blueAccent,
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
                                      Icons.map,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Parcelle: $pName",
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
