class Incident {
  final String description;
  final String type;
  final String location;
  final String region;
  final double latitude;
  final double longitude;
  final String? status;

  Incident({
    required this.description,
    required this.type,
    required this.location,
    required this.region,
    required this.latitude,
    required this.longitude,
    this.status,
  });

  Map<String, String> toFields() {
    return {
      'description': description,
      'type': type,
      'location': location,
      'region': region,
      'latitude': latitude.toStringAsFixed(6),
      'longitude': longitude.toStringAsFixed(6),
    };
  }

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      description: json['description'],
      type: json['type'],
      location: json['location'],
      region: json['region'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      status: json['status'],
    );
  }
}
