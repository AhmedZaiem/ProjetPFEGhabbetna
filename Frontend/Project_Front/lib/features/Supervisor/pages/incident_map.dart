import 'package:flutter/material.dart';

class IncidentMap extends StatefulWidget {
  const IncidentMap({super.key});

  @override
  State<IncidentMap> createState() => _IncidentMapState();
}

class _IncidentMapState extends State<IncidentMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incident Map')),
      body: const Center(
        child: Text('Map of Incidents will be displayed here.'),
      ),
    );
  }
}
