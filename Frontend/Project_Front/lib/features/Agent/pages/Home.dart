import 'package:flutter/material.dart';
import 'package:authproject/l10n/app_localizations.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:authproject/features/Agent/services/incident_service.dart';
import 'package:authproject/features/Supervisor/models/incidentOut.dart';
import 'package:authproject/features/Admin/services/user_service.dart';
import 'package:authproject/main.dart';

import 'upload.dart';
import 'package:authproject/features/Agent/models/incident.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService authService = AuthService();
  final IncidentService incidentService = IncidentService();
  final UserService userService = UserService();

  Map<String, dynamic>? userData;
  List<IncidentOut> incidents = [];

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    try {
      final userResult = await authService.getCurrentUser();
      if (!userResult['success']) {
        setState(() { error = userResult['message']; loading = false; });
        return;
      }
      final user = userResult['data'];
      final userId = user['id'];
      final incidentList = await incidentService.getIncidentsByUserId(userId);
      setState(() { userData = user; incidents = incidentList; loading = false; });
      syncScore(userId);
    } catch (e) {
      setState(() { error = e.toString(); loading = false; });
    }
  }

  int calculateScore() {
    if (incidents.isEmpty) return 0;
    final total = incidents.length;
    final accepted = incidents.where((i) => i.status == "accepted").length;
    if (total == 0) return 0;
    return ((accepted / total) * 100).round();
  }

  Future<void> syncScore(int userId) async {
    final score = calculateScore();
    try {
      await userService.updateUserScore(userId, score);
      setState(() { userData = { ...?userData, 'score': score }; });
    } catch (e) {
      print("Error syncing score: $e");
    }
  }

  int countStatus(String status) =>
      incidents.where((i) => i.status == status).length;

  // ── Stat card ──────────────────────────────────────────────────────────────
  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border(
            top: BorderSide(color: color, width: 3),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status chip ────────────────────────────────────────────────────────────
  Widget _buildStatusChip(String? status) {
    Color color;
    String text;
    IconData icon;
    final t = AppLocalizations.of(context)!;

    switch (status) {
      case "accepted":
        color = Colors.green.shade600;
        text = t.accepted_incident;
        icon = Icons.check_circle_outline_rounded;
        break;
      case "pending":
        color = Colors.orange.shade700;
        text = t.pending_incident;
        icon = Icons.hourglass_top_rounded;
        break;
      case "not_accepted":
        color = Colors.red.shade600;
        text = t.not_accepted_incident;
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey.shade500;
        text = "Unknown";
        icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(body: Center(child: Text(error!)));
    }

    final firstname = userData?['firstname'] ?? '';
    final lastname = userData?['lastname'] ?? '';
    final role = userData?['role_name'] ?? '';
    final score = userData?['score'] ?? 0;

    final pending  = countStatus("pending");
    final accepted = countStatus("accepted");
    final rejected = countStatus("not_accepted");

    final latestIncidents = incidents.take(3).toList();

    // Score color: red → orange → green
    final Color scoreColor = score >= 70
        ? Colors.green.shade600
        : score >= 40
            ? Colors.orange.shade700
            : Colors.red.shade600;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        centerTitle: true,
        title: Text(t.agent_home),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (value) {
              switch (value) {
                case 'en':
                  (mainAppKey.currentState)?.setLocale(const Locale('en', 'US'));
                  break;
                case 'fr':
                  (mainAppKey.currentState)?.setLocale(const Locale('fr', 'FR'));
                  break;
                case 'ar':
                  (mainAppKey.currentState)?.setLocale(const Locale('ar', 'AR'));
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text("English")),
              const PopupMenuItem(value: 'fr', child: Text("Français")),
              const PopupMenuItem(value: 'ar', child: Text("العربية")),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Welcome banner ─────────────────────────────────────────
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF1B5E20), const Color.fromARGB(255, 18, 62, 21)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 25, 77, 28).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Name + role
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${t.agent_hello},",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "$firstname $lastname",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.work_outline_rounded,
                                color: Colors.white70,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                role,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Score badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4), width: 1),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 16),
                          const SizedBox(height: 2),
                          Text(
                            "$score%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            t.agent_score,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Stats row ──────────────────────────────────────────────
              Row(
                children: [
                  _buildStatCard(
                    label: t.agent_pending,
                    value: "$pending",
                    color: Colors.orange.shade700,
                    icon: Icons.hourglass_top_rounded,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    label: t.agent_accepted,
                    value: "$accepted",
                    color: Colors.green.shade600,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    label: t.agent_rejected,
                    value: "$rejected",
                    color: Colors.red.shade600,
                    icon: Icons.cancel_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Latest incidents header ────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.agent_Latest_Incidents,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                      letterSpacing: 0.1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${latestIncidents.length}",
                      style: TextStyle(
                        color: const Color(0xFF1B5E20),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Incident list ─────────────────────────────────────────
              latestIncidents.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: latestIncidents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final incident = latestIncidents[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.report_outlined,
                                color: const Color.fromARGB(255, 21, 74, 25),
                                size: 22,
                              ),
                            ),
                            title: Text(
                              incident.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 13,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      incident.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: _buildStatusChip(incident.status),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              "No incidents yet",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}