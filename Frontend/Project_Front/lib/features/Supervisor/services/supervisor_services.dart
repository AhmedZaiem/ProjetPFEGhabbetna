import 'package:authproject/features/Admin/models/forest_model.dart';
import 'package:authproject/features/Supervisor/models/incidentOut.dart';
import '../../../config.dart' as config;
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SupervisorServices {
  final String baseUrl = config.baseUrl;

  Future<List<Forest>> getforestsbySupervisorId(int supervisorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/forest/supervisor/$supervisorId'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Forest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch forests for supervisor');
    }
  }

  Future<List<IncidentOut>> fetchIncidentsByForestids(
    List<int> forestIds,
  ) async {
    final idsQuery = forestIds.map((id) => 'forest_ids=$id').join('&');
    final response = await http.get(
      Uri.parse('$baseUrl/incidents/forests?$idsQuery'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => IncidentOut.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch incidents');
    }
  }
}
