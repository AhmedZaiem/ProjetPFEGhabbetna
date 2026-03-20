import 'package:authproject/config.dart' as config;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/parcelle_model.dart';

class ParcelService {
  final String baseUrl = config.baseUrl;

  Future<List<Parcel>> getParcels() async {
    final response = await http.get(Uri.parse("$baseUrl/parcelles"));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((f) => Parcel.fromJson(f)).toList();
    }

    throw Exception("Failed to load forests");
  }

  Future<Parcel> getParcelById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/parcelles/$id"));

    if (response.statusCode == 200) {
      return Parcel.fromJson(jsonDecode(response.body));
    }

    throw Exception("Parcel not found");
  }

  Future<void> createParcel(ParcelCreate parcel) async {
    final response = await http.post(
      Uri.parse("$baseUrl/parcelles"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(parcel.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create parcel");
    }
  }

  Future<void> deleteParcel(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/parcelles/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete parcel");
    }
  }
}
