import 'package:flutter/material.dart';
import 'package:authproject/features/Admin/models/user_model.dart';
import 'package:authproject/features/Admin/models/forest_model.dart';
import 'package:authproject/features/Admin/services/forest_service.dart';
import 'package:authproject/features/Admin/services/user_service.dart';
import 'package:authproject/features/Admin/ui_components/assignment_card.dart';
import 'package:authproject/features/Admin/ui_components/custom_dropdown.dart';
import 'package:authproject/l10n/app_localizations.dart';

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

  Map<int, UserModel> assignedSupervisors = {};
  Map<int, String> supervisorForestMap = {};

  Forest? selectedForest;
  UserModel? selectedUserForForest;

  int totalSupervisors = 0;
  int totalAssignedSupervisors = 0;
  int totalUnassignedSupervisors = 0;

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
      final allUsers = await userService.fetchUsers();

      assignedSupervisors.clear();
      supervisorForestMap.clear();

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

      final supervisorsOnly = allUsers
          .where((u) => u.role_name == "Superviseur")
          .toList();

      totalSupervisors = supervisorsOnly.length;
      totalUnassignedSupervisors = unassigned.length;
      totalAssignedSupervisors = totalSupervisors - totalUnassignedSupervisors;

      setState(() {
        forests = allForests.where((f) => f.supervisorId == null).toList();
        unassignedSupervisor = unassigned;
        selectedForest = null;
        selectedUserForForest = null;
        loading = false;
      });
    } catch (e) {
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
              Text(t.admin_assign_supervisor_title),
            ],
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              // ================= STATS =================
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      t.admin_total_supervisors,
                      "$totalSupervisors",
                      Icons.groups
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      t.admin_assigned_supervisors,
                      "$totalAssignedSupervisors",
                      Icons.verified_user
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      t.admin_unassigned,
                      "$totalUnassignedSupervisors",
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
                      title: t.admin_assign_supervisor_title,
                      children: [
                        CustomDropdown(
                          value: selectedUserForForest,
                          hint: t.admin_select,
                          items: unassignedSupervisor,
                          label: (u) => "${u.username} - ${u.region}",
                          onChanged: (u) =>
                              setState(() => selectedUserForForest = u),
                        ),

                        const SizedBox(height: 12),

                        CustomDropdown(
                          value: selectedForest,
                          hint: t.admin_assign_supervisor_forest,
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
                            label: Text(t.admin_assign_button),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
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
                      title: t.admin_assigned_supervisors,
                      children: assignedSupervisors.isEmpty
                          ? [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  t.admin_no_supervisors_assigned,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ]
                          : assignedSupervisors.entries.map<Widget>((e) {
                              final u = e.value;
                              final fName =
                                  supervisorForestMap[e.key] ?? t.admin_no_data;

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
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
                                          backgroundColor: Colors.green,
                                          child: Text(
                                            u.username[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.person, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          u.username,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    _infoRow(
                                      Icons.badge,
                                      "${t.admin_first_name}: ${u.firstname}",
                                    ),
                                    const SizedBox(height: 6),

                                    _infoRow(
                                      Icons.badge_outlined,
                                      "${t.admin_last_name}: ${u.lastname}",
                                    ),
                                    const SizedBox(height: 8),

                                    _infoRow(
                                      Icons.location_on,
                                      "${t.admin_region}: ${u.region}",
                                    ),
                                    const SizedBox(height: 6),

                                    _infoRow(
                                      Icons.park,
                                      "${t.admin_forest_name}: $fName",
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

  // ================= STATS CARD =================
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

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(text)],
    );
  }
}
