import 'package:authproject/features/Supervisor/models/incidentOut.dart';
import 'package:flutter/material.dart';

void showIncidentDetails(BuildContext context, IncidentOut incident) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Incident Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (incident.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  incident.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 10),

            Text("📄 ${incident.description}"),
            Text("📍 ${incident.location}"),
            Text("Status: ${incident.status}"),

            if (incident.comment != null) Text("💬 ${incident.comment}"),
          ],
        ),
      );
    },
  );
}
