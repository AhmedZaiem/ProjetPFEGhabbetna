import 'package:authproject/features/Admin/models/security_event.dart';
import 'package:authproject/features/Admin/services/security_services.dart';
import 'package:flutter/material.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  SecurityServices securityServices = SecurityServices();
  List<SecurityEvent> loglist = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final events = await securityServices.getFailedLoginEvents();
      setState(() {
        loglist = events;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
    }
  }

  Color _getRiskColor(String? risk) {
    switch (risk?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getRiskIcon(String? risk) {
    switch (risk?.toLowerCase()) {
      case 'high':
        return Icons.warning_rounded;
      case 'medium':
        return Icons.error_outline_rounded;
      case 'low':
        return Icons.info_outline_rounded;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getAttackIcon(String? attackType) {
    switch (attackType?.toLowerCase()) {
      case 'brute_force':
      case 'brute force':
        return Icons.lock_outline;
      case 'credential_stuffing':
        return Icons.manage_accounts_outlined;
      case 'phishing':
        return Icons.phishing_outlined;
      case 'ddos':
        return Icons.cloud_off_outlined;
      default:
        return Icons.security_outlined;
    }
  }

  List<Widget> _buildRiskSummary() {
    final counts = <String, int>{};
    for (final e in loglist) {
      final r = e.risk_level?.toLowerCase() ?? 'unknown';
      counts[r] = (counts[r] ?? 0) + 1;
    }
    final colorMap = {
      'high': Colors.red,
      'medium': Colors.orange,
      'low': Colors.green,
    };
    return counts.entries.map((entry) {
      final color = colorMap[entry.key] ?? Colors.grey;
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
              '${entry.value} ${entry.key}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Security Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const Icon(Icons.shield_outlined, color: Colors.black87),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : loglist.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No security events found',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // ── Counter Bar ──────────────────────────────────
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 16,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${loglist.length} ${loglist.length == 1 ? 'event' : 'events'}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ..._buildRiskSummary(),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // ── Event Cards ──────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: loglist.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final event = loglist[index];
                      final riskColor = _getRiskColor(event.risk_level);

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
                              // ── Row 1: attack icon + email/type + risk badge ──
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: riskColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getAttackIcon(event.attack_type),
                                      color: riskColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.email ?? 'Unknown email',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${event.event_type ?? 'Unknown'} · ${event.attack_type ?? 'Unknown'}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Risk badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: riskColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: riskColor.withOpacity(0.4),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getRiskIcon(event.risk_level),
                                          size: 12,
                                          color: riskColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          event.risk_level ?? 'N/A',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: riskColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),
                              const Divider(height: 1),
                              const SizedBox(height: 10),

                              // ── Summary + Recommendation ──
                              if (event.summary != null) ...[
                                Text(
                                  event.summary!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                              ],
                              if (event.recommendation != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outline,
                                        size: 13,
                                        color: Colors.blue.shade600,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          event.recommendation!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue.shade700,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 10),
                              const Divider(height: 1),
                              const SizedBox(height: 8),

                              // ── Footer: IP + timestamp ──
                              Row(
                                children: [
                                  _InfoChip(
                                    icon: Icons.router_outlined,
                                    label: event.ip_adresse ?? 'N/A',
                                  ),
                                  const Spacer(),
                                  _InfoChip(
                                    icon: Icons.access_time_outlined,
                                    label: event.timestamp != null
                                        ? '${event.timestamp.toLocal()}'
                                        : 'Unknown time',
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
