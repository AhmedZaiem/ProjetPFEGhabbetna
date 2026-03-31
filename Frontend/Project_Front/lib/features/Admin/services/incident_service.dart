import 'package:authproject/features/Admin/models/incident.dart';
import 'package:authproject/config.dart' as config;
import 'package:http/http.dart' as http;
import 'dart:convert';

class IncidentService {
  final String baseUrl = config.baseUrl;


  Future<List<Incident>> getAllIncidents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/incidents/'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Incident.fromJson(json)).toList();
    } else {
      throw Exception(
        jsonDecode(response.body)["detail"] ?? "Failed to fetch incidents",
      );
    }
  }
}
