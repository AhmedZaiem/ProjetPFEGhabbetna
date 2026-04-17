import 'package:flutter/material.dart';
import 'package:authproject/features/Agent/models/incident.dart';
import 'package:authproject/features/Agent/services/incident_service.dart';

import 'package:authproject/l10n/app_localizations.dart';

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
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Incident History"),
      ),
    );
  }
}
