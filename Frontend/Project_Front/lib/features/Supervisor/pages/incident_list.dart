import 'package:authproject/features/Admin/models/forest_model.dart';
import 'package:authproject/features/Admin/models/incident.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:authproject/features/Supervisor/services/supervisor_services.dart';
import 'package:flutter/material.dart';
import 'package:authproject/features/Supervisor/models/incidentOut.dart';

class IncidentList extends StatefulWidget {
  const IncidentList({super.key});

  @override
  State<IncidentList> createState() => _IncidentListState();
}

class _IncidentListState extends State<IncidentList> {
  AuthService authService = AuthService();
  Map<String, dynamic>? userData;
  String? error;
  SupervisorServices supervisorServices = SupervisorServices();
  List<Forest>? forests;
  List<IncidentOut>? incidentData;

  Future<void> initData() async {
    final result = await authService.getCurrentUser();
    print('getCurrentUser result: $result');
    if (!result['success']) {
      setState(() => error = result['message']);
      return;
    }

    final user = result['data'];
    final supervisorId = user['id'];

    try {
      final fetchedForests = await supervisorServices.getforestsbySupervisorId(
        supervisorId,
      );
      print('Fetched forests: $fetchedForests');
      if (fetchedForests.isEmpty) {
        setState(() => error = 'No forests assigned to this supervisor.');
        return;
      }

      final forestIds = fetchedForests.map((f) => f.id).toList();
      final incidents = await supervisorServices.fetchIncidentsByForestids(
        forestIds,
      );
      print('Fetched incidents: $incidents');
      setState(() {
        userData = user;
        forests = fetchedForests;
        incidentData = incidents;
      });
      print('User Data: $userData');
      print('Forests: $forests');
      print('Incident Data: $incidentData');
    } catch (e) {
      setState(() => error = 'Failed to fetch forests: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    print('IncidentList initState called');
    initData();
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'not_accepted':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incident List')),
      body: incidentData == null
          ? const Center(child: CircularProgressIndicator())
          : incidentData!.isEmpty
          ? const Center(child: Text("No incidents found"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FlexColumnWidth(3), // Description
                  1: FlexColumnWidth(2), // Type
                  2: FlexColumnWidth(2), // Region
                  3: FlexColumnWidth(2), // Status
                  4: FlexColumnWidth(2), // Location
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  // Header
                  const TableRow(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 212, 198, 198),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Description",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Type",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Region",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Location",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Incident rows
                  ...incidentData!.map<TableRow>((incident) {
                    return TableRow(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ), // alternating colors if you want
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(incident.description),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(incident.type),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(incident.region),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            incident.status ?? 'N/A',
                            style: TextStyle(
                              color: _getStatusColor(incident.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            "${incident.latitude.toStringAsFixed(4)}, ${incident.longitude.toStringAsFixed(4)}",
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
