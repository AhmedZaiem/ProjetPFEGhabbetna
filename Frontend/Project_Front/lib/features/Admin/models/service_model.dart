class ServiceModel {
  final int id;
  final String name;
  final String type;
  final String? description;
  final DateTime createdAt;

  ServiceModel({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.createdAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "type": type,
      "description": description,
    };
  }
}