import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:authproject/config.dart' as config;

class IncidentBIService {
  final String baseUrl = config.baseUrl;

  Future<List<Map<String, dynamic>>> getIncidentsOverTime() async {
    final response = await http.get(
      Uri.parse("$baseUrl/bi_incidents/over-time"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }

    throw Exception("Failed to load incidents over time");
  }

  Future<List<Map<String, dynamic>>> getIncidentsByStatus() async {
    final response = await http.get(
      Uri.parse("$baseUrl/bi_incidents/by-status"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }

    throw Exception("Failed to load incidents by status");
  }

  Future<List<Map<String, dynamic>>> getIncidentsByRegion() async {
    final response = await http.get(
      Uri.parse("$baseUrl/bi_incidents/by-region"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }

    throw Exception("Failed to load incidents by region");
  }

  Future<List<Map<String, dynamic>>> getTopForests() async {
    final response = await http.get(
      Uri.parse("$baseUrl/bi_incidents/top-forests"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }

    throw Exception("Failed to load top forests");
  }

  Future<List<Map<String, dynamic>>> getTopAgents() async {
    final response = await http.get(
      Uri.parse("$baseUrl/bi_incidents/top-agents"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }

    throw Exception("Failed to load top agents");
  }
}
