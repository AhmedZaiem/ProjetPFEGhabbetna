import 'package:flutter/material.dart';
import 'package:authproject/features/Admin/models/incident.dart';
import 'package:authproject/features/Admin/services/incident_service.dart';

class ManageIncident extends StatefulWidget {
  const ManageIncident({super.key});

  @override
  State<ManageIncident> createState() => _ManageIncidentState();
}

class _ManageIncidentState extends State<ManageIncident> {
  final IncidentService _incidentService = IncidentService();
  late Future<List<Incident>> _incidentsFuture;

  @override
  void initState() {
    super.initState();
    _incidentsFuture = _incidentService.getAllIncidents();
  }

  Future<void> _refreshIncidents() async {
    setState(() {
      _incidentsFuture = _incidentService.getAllIncidents();
    });
  }

  Widget _buildCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: 140,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              FittedBox(
                child: Text(
                  count,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logoApp.jpeg', height: 80),
            const SizedBox(width: 12),
            const Text("Manage Incidents"),
          ],
        ),
      ),
      body: FutureBuilder<List<Incident>>(
        future: _incidentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No incidents found.'));
          }

          final incidents = snapshot.data!;
          final totalIncidents = incidents.length;
          final pendingIncidents = incidents
              .where((i) => i.status == "pending")
              .length;
          final acceptedIncidents = incidents
              .where((i) => i.status == "accepted")
              .length;
          final notAcceptedIncidents = incidents
              .where((i) => i.status == "not_accepted")
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildCard(
                      "Total Incidents",
                      totalIncidents.toString(),
                      Icons.report,
                      const Color.fromARGB(255, 0, 0, 0),
                    ),
                    const SizedBox(width: 12),
                    _buildCard(
                      "Pending Incidents",
                      pendingIncidents.toString(),
                      Icons.verified,
                      const Color.fromARGB(255, 0, 128, 0),
                    ),
                    const SizedBox(width: 12),
                    _buildCard(
                      "Accepted Incidents",
                      acceptedIncidents.toString(),
                      Icons.check_circle,
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildCard(
                      "Not Accepted",
                      notAcceptedIncidents.toString(),
                      Icons.cancel,
                      Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: incidents.length,
                  itemBuilder: (context, index) {
                    final incident = incidents[index];
                    return Card(
                      color: const Color(0xFF1B5E20),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Type with icon
                            Row(
                              children: [
                                const Icon(
                                  Icons.warning,
                                  color: Colors.yellowAccent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    incident.type,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Description
                            Text(
                              incident.description,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 6),

                            // Location with icon
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${incident.location}, ${incident.region}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Coordinates
                            Row(
                              children: [
                                const Icon(
                                  Icons.map,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${incident.latitude.toStringAsFixed(6)}, ${incident.longitude.toStringAsFixed(6)}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),

                            // Status tag
                            if (incident.status != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  incident.status!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
