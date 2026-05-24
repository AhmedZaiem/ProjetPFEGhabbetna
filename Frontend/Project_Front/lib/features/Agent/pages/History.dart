import 'package:authproject/features/Supervisor/models/incidentOut.dart';
import 'package:flutter/material.dart';
import 'package:authproject/features/Agent/services/incident_service.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:authproject/l10n/app_localizations.dart';
import '../ui_components/history_components.dart';
import 'package:authproject/main.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistotyState();
}

class _HistotyState extends State<History> {
  final IncidentService _incidentService = IncidentService();
  late Future<List<IncidentOut>> _incidentsFuture;
  final authService = AuthService();
  String? error;

  @override
  void initState() {
    super.initState();
    _incidentsFuture = loadData();
  }

  Future<List<IncidentOut>> loadData() async {
    final userid = await authService.getUserIdFromToken();
    if (userid == null) {
      setState(() => error = 'User not authenticated.');
      return [];
    }
    return await _incidentService.getIncidentsByUserId(userid);
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    String text;
    final t = AppLocalizations.of(context)!;

    switch (status?.toLowerCase()) {
      case 'accepted':
        color = Colors.green;
        text = t.accepted_incident;
        break;
      case 'pending':
        color = Colors.orange;
        text = t.pending_incident;
        break;
      case 'not_accepted':
        color = Colors.red;
        text = t.not_accepted_incident;
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(t.agent_history),

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
      body: error != null
          ? Center(child: Text(error!))
          : FutureBuilder<List<IncidentOut>>(
              future: _incidentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("no incidents found"));
                } else {
                  final incidents = snapshot.data!;
                  return ListView.builder(
                    itemCount: incidents.length,
                    itemBuilder: (context, index) {
                      final incident = incidents[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => showIncidentDetails(context, incident),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image
                                if (incident.imageUrl != null &&
                                    incident.imageUrl!.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      incident.imageUrl!,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Description + status
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              incident.description,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          _buildStatusChip(incident.status),
                                        ],
                                      ),

                                      const SizedBox(height: 10),

                                      // Type
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.category,
                                            size: 16,
                                            color: Color.fromARGB(255, 86, 53, 20),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              incident.type,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // Region
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.map,
                                            size: 16,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            incident.region,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // Location
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              incident.location ?? "",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // Coordinates
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.gps_fixed,
                                            size: 16,
                                            color: Colors.deepPurple,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              "${incident.latitude.toStringAsFixed(5)}, "
                                              "${incident.longitude.toStringAsFixed(5)}",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      

                                      // Comment
                                      if (incident.comment != null &&
                                          incident.comment!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text("💬 "),
                                              Expanded(
                                                child: Text(
                                                  incident.comment!,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
    );
  }
}
