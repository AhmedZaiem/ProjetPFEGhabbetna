import 'package:authproject/features/Admin/models/forest_model.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:authproject/features/Supervisor/models/parcelleWithAgent.dart';
import 'package:authproject/features/Supervisor/services/supervisor_services.dart';
import 'package:authproject/features/Supervisor/models/agent.dart';
import 'package:authproject/l10n/app_localizations.dart';

class AgentList extends StatefulWidget {
  const AgentList({super.key});

  @override
  State<AgentList> createState() => _AgentListState();
}

class _AgentListState extends State<AgentList> {
  List<Parcellewithagent> parcellesWithAgents = [];
  final SupervisorServices supervisorServices = SupervisorServices();
  final AuthService authService = AuthService();
  List<Agent> agents = [];
  List<Forest>? forests;
  String? error;
  bool isLoading = true;

  Future<void> initData() async {
    final supervisorId = await authService.getUserIdFromToken();
    if (supervisorId == null) {
      setState(() {
        error = 'User not authenticated.';
        isLoading = false;
      });
      return;
    }

    try {
      final fetchedForests = await supervisorServices.getforestsbySupervisorId(
        supervisorId,
      );
      if (fetchedForests.isEmpty) {
        setState(() {
          error = 'No forests assigned to this supervisor.';
          isLoading = false;
        });
        return;
      }

      final forestIds = fetchedForests.map((f) => f.id).toList();
      final fetchedParcelles = await supervisorServices.getParcellesByForestIds(
        forestIds,
      );

      setState(() {
        forests = fetchedForests;
        parcellesWithAgents = fetchedParcelles;
        agents = fetchedParcelles
            .where((p) => p.agent != null)
            .map((p) => p.agent!)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to fetch data: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  Color _getScoreColor(num score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.teal,
      Colors.indigo,
      Colors.deepPurple,
      Colors.blue,
      Colors.cyan,
      Colors.green.shade700,
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Text(
              t.supervisor_agent_list,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(error!, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            )
          : agents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No agents found',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // ── Counter Bar ──────────────────────────────
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Total badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_alt_outlined,
                              size: 16,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${agents.length} ${agents.length == 1 ? 'agent' : 'agents'}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Score breakdown
                      ..._buildScoreSummary(),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // ── Agent Cards ──────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: agents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final agent = agents[index];
                      final scoreColor = _getScoreColor(agent.score);
                      final avatarColor = _getAvatarColor(agent.name);

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Row 1: avatar + name/email + score ──
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Avatar with initials
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: avatarColor,
                                    child: Text(
                                      _getInitials(agent.name),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          agent.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          agent.email,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Score badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: scoreColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: scoreColor.withOpacity(0.4),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star_outline,
                                          size: 13,
                                          color: scoreColor,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${agent.score}%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: scoreColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 10),

                              // ── Row 2: tel + region ──
                              Row(
                                children: [
                                  _InfoChip(
                                    icon: Icons.phone_outlined,
                                    label: agent.tel,
                                  ),
                                  const SizedBox(width: 16),
                                  _InfoChip(
                                    icon: Icons.forest_outlined,
                                    label: agent.region,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildScoreSummary() {
    final high = agents.where((a) => a.score >= 75).length;
    final mid = agents.where((a) => a.score >= 50 && a.score < 75).length;
    final low = agents.where((a) => a.score < 50).length;

    return [
      if (high > 0) _ScoreDot(color: Colors.green, label: '$high high'),
      if (mid > 0) _ScoreDot(color: Colors.orange, label: '$mid mid'),
      if (low > 0) _ScoreDot(color: Colors.red, label: '$low low'),
    ];
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _ScoreDot extends StatelessWidget {
  final Color color;
  final String label;

  const _ScoreDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
