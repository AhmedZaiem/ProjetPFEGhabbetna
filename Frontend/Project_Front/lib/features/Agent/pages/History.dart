import 'package:flutter/material.dart';
import 'package:authproject/features/Agent/models/incident.dart';
import 'package:authproject/features/Agent/services/incident_service.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistotyState();
}

class _HistotyState extends State<History> {
  final IncidentService _incidentService = IncidentService();
  late Future<List<Incident>> _incidentsFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Incident History"),
      ),
    );
  }
}
