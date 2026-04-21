import 'package:flutter/material.dart';
import 'package:authproject/features/Admin/models/incident.dart';
import 'package:authproject/features/Admin/services/incident_service.dart';
import 'package:authproject/features/Supervisor/models/incidentOut.dart';
import 'package:authproject/l10n/app_localizations.dart';

class ManageIncident extends StatefulWidget {
  const ManageIncident({super.key});

  @override
  State<ManageIncident> createState() => _ManageIncidentState();
}

class _ManageIncidentState extends State<ManageIncident> {
  final IncidentService _incidentService = IncidentService();
  late Future<List<IncidentOut>> _incidentsFuture;

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

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Text("Failed to load image"),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logoApp.jpeg', height: 80),
            const SizedBox(width: 12),
            Text(t.admin_manage_incidents),
          ],
        ),
      ),
      body: FutureBuilder<List<IncidentOut>>(
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
                      t.admin_total_incidents,
                      totalIncidents.toString(),
                      Icons.report,
                      const Color.fromARGB(255, 0, 0, 0),
                    ),
                    const SizedBox(width: 12),
                    _buildCard(
                      t.admin_pending_incidents,
                      pendingIncidents.toString(),
                      Icons.verified,
                      const Color.fromARGB(255, 0, 0, 0),
                    ),
                    const SizedBox(width: 12),
                    _buildCard(
                      t.admin_accepted_incidents,
                      acceptedIncidents.toString(),
                      Icons.check_circle,
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildCard(
                      t.admin_not_accepted_incidents,
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
                      color: Colors.white,
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
                            // ================= TYPE =================
                            Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    incident.type,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // ================= DESCRIPTION =================
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.description,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${t.admin_description} : ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    incident.description,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // ================= LOCATION =================
                            Row(
                              children: [
                                const Icon(
                                  Icons.place,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${t.admin_Location} : ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    incident.location,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // ================= REGION =================
                            Row(
                              children: [
                                const Icon(
                                  Icons.map,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "${t.admin_region} : ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    incident.region,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // ================= COORDINATES =================
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "${t.admin_Coordinates} : ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "${incident.latitude.toStringAsFixed(6)}, "
                                    "${incident.longitude.toStringAsFixed(6)}",
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // ================= STATUS =================
                            if (incident.status != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
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

                            if (incident.imageUrl != null &&
                                incident.imageUrl!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _showImageDialog(incident.imageUrl!),
                                      icon: const Icon(Icons.image),
                                      label: Text(t.admin_view_image),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
