import 'package:flutter/material.dart';

class IncidentList extends StatefulWidget {
  const IncidentList({super.key});

  @override
  State<IncidentList> createState() => _IncidentListState();
}

class _IncidentListState extends State<IncidentList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incident List')),
      body: const Center(
        child: Text('List of Incidents will be displayed here.'),
      ),
    );
  }
}
