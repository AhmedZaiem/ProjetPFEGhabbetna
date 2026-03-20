class Coordinates {
  final double lng;
  final double lat;

  Coordinates({required this.lng, required this.lat});

  Map<String, dynamic> toJson() {
    return {"lng": lng, "lat": lat};
  }

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(lng: json["lng"], lat: json["lat"]);
  }
}
