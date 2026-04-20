import 'package:flutter/material.dart';
import 'package:authproject/features/Admin/models/user_model.dart';
import 'package:authproject/features/Admin/models/parcelle_model.dart';
import 'package:authproject/features/Admin/services/parcelle_service.dart';
import 'package:authproject/features/Admin/services/user_service.dart';
import 'package:authproject/features/Admin/ui_components/assignment_card.dart';
import 'package:authproject/features/Admin/ui_components/custom_dropdown.dart';
import 'package:authproject/l10n/app_localizations.dart';

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

  Map<int, UserModel> assignedAgents = {};
  Map<int, String> agentParcelMap = {};

  Parcel? selectedParcel;
  UserModel? selectedUserForParcel;

  int totalAgents = 0;
  int totalAssignedAgents = 0;
  int totalUnassignedAgents = 0;

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

      assignedAgents.clear();
      agentParcelMap.clear();

      final allUsers = await userService.fetchUsers();

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

      // stat
      final agentsOnly = allUsers.where((u) => u.role_name == "Agent").toList();

      totalAgents = agentsOnly.length;
      totalUnassignedAgents = unassigned.length;
      totalAssignedAgents = totalAgents - totalUnassignedAgents;

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
        SnackBar(content: Text(AppLocalizations.of(context)!.admin_success)),
      );

      await loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.admin_error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/images/logoApp.jpeg', height: 80),
              const SizedBox(width: 12),
              Text(t.admin_assign_agent_title),
            ],
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              // ================= TOP STATS =================
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      t.admin_total_agents,
                      "$totalAgents",
                      Icons.groups
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      t.admin_assigned_agents,
                      "$totalAssignedAgents",
                      Icons.verified_user
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      t.admin_unassigned,
                      "$totalUnassignedAgents",
                      Icons.person_off
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= FORM (40%) =================
                  Expanded(
                    flex: 4,
                    child: AssignmentCard(
                      title: t.admin_assign_agent_title,
                      children: [
                        CustomDropdown(
                          value: selectedUserForParcel,
                          hint: t.admin_select,
                          items: unassignedAgents,
                          label: (u) => "${u.username} - ${u.region}",
                          onChanged: (u) =>
                              setState(() => selectedUserForParcel = u),
                        ),

                        const SizedBox(height: 12),

                        CustomDropdown(
                          value: selectedParcel,
                          hint: t.admin_assign_agent_parcelle,
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
                            label: Text(t.admin_assign_button),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
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

                  const SizedBox(width: 16),

                  // ================= LIST (60%) =================
                  Expanded(
                    flex: 6,
                    child: AssignmentCard(
                      title: t.admin_assigned_agents,
                      children: assignedAgents.isEmpty
                          ? [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  t.admin_no_agents_assigned,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ]
                          : assignedAgents.entries.map<Widget>((e) {
                              final u = e.value;
                              final pName =
                                  agentParcelMap[e.key] ?? t.admin_no_data;

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
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
                                        const Icon(Icons.person, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${t.admin_username}: ${u.username}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    Row(
                                      children: [
                                        const Icon(Icons.badge, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${t.admin_first_name}: ${u.firstname}",
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.badge_outlined,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${t.admin_last_name}: ${u.lastname}",
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 18),
                                        const SizedBox(width: 6),
                                        Text("${t.admin_region}: ${u.region}"),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    Row(
                                      children: [
                                        const Icon(Icons.map, size: 18),
                                        const SizedBox(width: 6),
                                        Text("${t.admin_parcel}: $pName"),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: const Color.fromARGB(255, 0, 0, 0)),
          const SizedBox(height: 8),
          Text(
            value.isEmpty ? "—" : value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(title),
        ],
      ),
    );
  }
}
