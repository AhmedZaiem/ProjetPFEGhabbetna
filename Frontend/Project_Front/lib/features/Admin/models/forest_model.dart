import 'coordinates.dart';

class Forest {
  final int id;
  final String name;
  final String? description;
  final double areaHectares;
  final String riskLevel;
  final List<Coordinates> boundary;
  final int? supervisorId;
  final String region;

  Forest({
    required this.id,
    required this.name,
    this.description,
    required this.areaHectares,
    required this.riskLevel,
    required this.boundary,
    this.supervisorId,
    required this.region,
  });

  factory Forest.fromJson(Map<String, dynamic> json) {
    return Forest(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      areaHectares: json["area_hectares"],
      riskLevel: json["risk_level"],
      boundary: (json["boundary"] as List)
          .map((e) => Coordinates.fromJson(e))
          .toList(),
      supervisorId: json["supervisor_id"],
      region: json["region"],
    );
  }
}

class ForestCreate {
  final String name;
  final String? description;
  final List<Coordinates> boundary;
  final String region;

  ForestCreate({
    required this.name,
    this.description,
    required this.boundary,
    required this.region,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "boundary": boundary.map((c) => c.toJson()).toList(),
      "region": region,
    };
  }
}
