import 'package:authproject/config.dart' as config;

class IncidentOut {
  final int? id;
  final String description;
  final String type;
  final String location;
  final String region;
  final double latitude;
  final double longitude;
  final String? status;
  final String? comment;
  final int? forestId;
  final String? imageUrl;
  final String? user_email;

  IncidentOut({
    this.id,
    required this.description,
    required this.type,
    required this.location,
    required this.region,
    required this.latitude,
    required this.longitude,
    this.status,
    this.comment,
    this.forestId,
    required this.imageUrl,
    required this.user_email,
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
      'user_email': user_email ?? '',
    };
    if (forestId != null) fields['forest_id'] = forestId.toString();
    if (imageUrl != null) fields['image_url'] = imageUrl!;
    return fields;
  }

  factory IncidentOut.fromJson(Map<String, dynamic> json) {
    final baseUrl = config.baseUrl;
    final imagePath = json['image_url'] ?? '';
    final fullImageUrl = imagePath.isNotEmpty ? '$baseUrl/$imagePath' : null;

    return IncidentOut(
      id: json['id'] ?? 0,
      description: json['description'],
      type: json['type'],
      location: json['location'],
      region: json['region'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: json['status'],
      comment: json['comment'],
      forestId: json['forest_id'],
      imageUrl: fullImageUrl,
      user_email: json['user_email'],
    );
  }
}
