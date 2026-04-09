import 'dart:convert';

import 'package:authproject/features/Agent/models/incident.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config.dart' as config;
import 'package:http_parser/http_parser.dart';

class IncidentService {
  final storage = FlutterSecureStorage();
  final String baseUrl = config.baseUrl;

  Future<bool> submitIncident(Incident incident, XFile imageFile) async {
    String? token = await storage.read(key: "access_token");
    if (token == null) return false;

    var url = Uri.parse("$baseUrl/incidents/add");
    var request = http.MultipartRequest("POST", url);

    request.headers["Authorization"] = "Bearer $token";

    request.fields.addAll(incident.toFields());

    var bytes = await imageFile.readAsBytes();

    final mimeType = imageFile.mimeType?.split('/');

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: imageFile.name,
        contentType: mimeType != null
            ? MediaType(mimeType[0], mimeType[1])
            : MediaType('image', 'jpeg'),
      ),
    );

    var response = await request.send();

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<Map<String, dynamic>> checkAssignedParcelle(int userId) async {
    final url = Uri.parse('$baseUrl/parcelles/assigned/$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"assigned": false, "parcelle": null};
      }
    } catch (e) {
      return {"assigned": false, "parcelle": null};
    }
  }

  Future<List<Incident>> getIncidentsByUserId(int userId) async {
    String? token = await storage.read(key: "access_token");
    if (token == null) return [];

    final url = Uri.parse("$baseUrl/incidents/user/$userId");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Incident.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching incidents for user $userId: $e");
      return [];
    }
  }
}
