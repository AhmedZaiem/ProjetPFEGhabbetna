import 'package:authproject/features/Admin/models/coordinates.dart';

import 'agent.dart';

class Parcellewithagent {
  final int id;
  final String name;
  final double areaHectares;
  final List<Coordinates> boundary;
  final int forestId;
  final String region;
  final Agent? agent;

  Parcellewithagent({
    required this.id,
    required this.name,
    required this.areaHectares,
    required this.boundary,
    required this.forestId,
    required this.region,
    this.agent,
  });

  factory Parcellewithagent.fromJson(Map<String, dynamic> json) {
    return Parcellewithagent(
      id: json['id'],
      name: json['name'],
      areaHectares: (json['area_hectares'] as num).toDouble(),
      boundary: (json['boundary'] as List)
          .map((c) => Coordinates.fromJson(c))
          .toList(),
      forestId: json['forest_id'],
      region: json['region'],
      agent: json['agent'] != null ? Agent.fromJson(json['agent']) : null,
    );
  }
}
