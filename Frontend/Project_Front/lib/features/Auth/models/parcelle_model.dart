import 'coordinates.dart';

class Parcel {
  final int id;
  final String name;
  final double areaHectares;
  final int forestId;
  final List<Coordinates> boundary;

  Parcel({
    required this.id,
    required this.name,
    required this.areaHectares,
    required this.forestId,
    required this.boundary,
  });

  factory Parcel.fromJson(Map<String, dynamic> json) {
    return Parcel(
      id: json["id"],
      name: json["name"],
      areaHectares: json["area_hectares"],
      forestId: json["forest_id"],
      boundary: (json["boundary"] as List)
          .map((e) => Coordinates.fromJson(e))
          .toList(),
    );
  }
}

class ParcelCreate {
  final String name;
  final List<Coordinates> boundary;

  ParcelCreate({required this.name, required this.boundary});

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "boundary": boundary.map((c) => c.toJson()).toList(),
    };
  }
}
