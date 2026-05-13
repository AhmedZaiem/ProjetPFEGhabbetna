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
        setState(() {
          error = userResult['message'];
          loading = false;
        });
        return;
      }

      final user = userResult['data'];
      final userId = user['id'];

      final incidentList = await incidentService.getIncidentsByUserId(userId);

      setState(() {
        userData = user;
        incidents = incidentList;
        loading = false;
      });

      syncScore(userId);
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
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

      setState(() {
        userData = {
          ...?userData,
          'score': score, // ensures UI always reflects latest score
        };
      });
    } catch (e) {
      print("Error syncing score: $e");
    }
  }

  int countStatus(String status) {
    return incidents.where((i) => i.status == status).length;
  }

  Widget buildCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatusChip(String? status) {
    Color color;
    String text;

    switch (status) {
      case "accepted":
        color = Colors.green;
        text = "Accepted";
        break;
      case "pending":
        color = Colors.orange;
        text = "Pending";
        break;
      case "not_accepted":
        color = Colors.red;
        text = "Rejected";
        break;
      default:
        color = Colors.grey;
        text = "Unknown";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
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

    final pending = countStatus("pending");
    final accepted = countStatus("accepted");
    final rejected = countStatus("not_accepted");

    final latestIncidents = incidents.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(t.agent_home),

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),

            onSelected: (value) {
              switch (value) {
                case 'en':
                  (mainAppKey.currentState)?.setLocale(
                    const Locale('en', 'US'),
                  );
                  break;

                case 'fr':
                  (mainAppKey.currentState)?.setLocale(
                    const Locale('fr', 'FR'),
                  );
                  break;

                case 'ar':
                  (mainAppKey.currentState)?.setLocale(
                    const Locale('ar', 'AR'),
                  );
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // HELLO
              Text(
                "${t.agent_hello} $firstname $lastname",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // ROLE
              Text(
                role,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),

              const SizedBox(height: 12),

              // SCORE
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${t.agent_score} : $score %",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // STATS CARDS
              Row(
                children: [
                  buildCard(t.agent_pending, "$pending", Colors.orange),
                  const SizedBox(width: 10),
                  buildCard(t.agent_accepted, "$accepted", Colors.green),
                  const SizedBox(width: 10),
                  buildCard(t.agent_rejected, "$rejected", Colors.red),
                ],
              ),

              const SizedBox(height: 20),

              // TITLE
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t.agent_Latest_Incidents,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // LIST
              Expanded(
                child: ListView.builder(
                  itemCount: latestIncidents.length,
                  itemBuilder: (context, index) {
                    final incident = latestIncidents[index];

                    return Card(
                      child: ListTile(
                        title: Text(incident.description),
                        subtitle: Text(incident.location),
                        trailing: buildStatusChip(incident.status),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
