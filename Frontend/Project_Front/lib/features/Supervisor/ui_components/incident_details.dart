import 'package:authproject/features/Supervisor/services/supervisor_services.dart';
import 'package:flutter/material.dart';
import 'package:authproject/features/Supervisor/models/incidentOut.dart';

SupervisorServices supervisorServices = SupervisorServices();

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

Widget buildIncidentDetails(
  BuildContext context,
  IncidentOut incident,
  VoidCallback refresh,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Center(
        child: Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      SizedBox(height: 16),

      Text(
        "Incident Details",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),

      SizedBox(height: 12),

      Row(
        children: [
          Chip(
            label: Text(incident.status ?? "Unknown"),
            backgroundColor: _getStatusColor(incident.status),
          ),
        ],
      ),

      SizedBox(height: 12),

      Text("📄 ${incident.description}"),
      Text("📍 ${incident.type}"),

      SizedBox(height: 12),

      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          incident.imageUrl ?? '',
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Text("No image available"),
        ),
      ),

      SizedBox(height: 16),

      if (incident.status?.toLowerCase() == 'pending')
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  try {
                    await supervisorServices.verifyIncident(
                      incident.id!,
                      'accepted',
                    );
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Incident Accepted'),
                        content: Text('The incident has been accepted.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                    refresh(); // Refresh data to update marker colors
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to verify incident: $e')),
                    );
                  }
                },
                child: Text("Accept"),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  try {
                    await supervisorServices.verifyIncident(
                      incident.id!,
                      'not_accepted',
                    );
                    Navigator.pop(
                      context,
                    ); // Close the bottom sheet before showing the dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Incident Rejected'),
                        content: Text('The incident has been rejected.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                    refresh(); // Refresh data to update marker colors
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to verify incident: $e')),
                    );
                  }
                },
                child: Text("Reject"),
              ),
            ),
          ],
        ),
    ],
  );
}
