class IncidentOut {
  final int? id;
  final String description;
  final String type;
  final String location;
  final String region;
  final double latitude;
  final double longitude;
  final String? status;
  final int? forestId;

  IncidentOut({
    this.id,
    required this.description,
    required this.type,
    required this.location,
    required this.region,
    required this.latitude,
    required this.longitude,
    this.status,
    this.forestId,
  });

  Map<String, String> toFields() {
    final fields = {
      'id': id.toString(),
      'description': description,
      'type': type,
      'location': location,
      'region': region,
      'latitude': latitude.toStringAsFixed(6),
      'longitude': longitude.toStringAsFixed(6),
    };
    if (forestId != null) fields['forest_id'] = forestId.toString();
    return fields;
  }

  factory IncidentOut.fromJson(Map<String, dynamic> json) {
    return IncidentOut(
      id: json['id'] ?? 0,
      description: json['description'],
      type: json['type'],
      location: json['location'],
      region: json['region'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: json['status'],
      forestId: json['forest_id'],
    );
  }
}
