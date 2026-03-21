import 'package:authproject/config.dart' as config;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/forest_model.dart';

class ForestService {
  final String baseUrl = config.baseUrl;

  Future<List<Forest>> getForests() async {
    final response = await http.get(Uri.parse("$baseUrl/forest"));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((f) => Forest.fromJson(f)).toList();
    }

    throw Exception("Failed to load forests");
  }

  Future<Forest> getForestById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/forest/$id"));

    if (response.statusCode == 200) {
      return Forest.fromJson(jsonDecode(response.body));
    }

    throw Exception("Forest not found");
  }

  Future<void> createForest(ForestCreate forest) async {
    final response = await http.post(
      Uri.parse("$baseUrl/forest"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(forest.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create forest");
    }
  }

  Future<void> deleteForest(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/forest/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete forest");
    }
  }

  Future<void> assignSupervisor(int forestId, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forest/$forestId/assign-supervisor/$userId'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)["detail"]);
    }
  }

  Future<List<Forest>> getFreeForests() async {
    final response = await http.get(
      Uri.parse("$baseUrl/forest/non_occupied_forests"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.map<Forest>((f) => Forest.fromJson(f)).toList();
    }

    throw Exception("Failed to load forests");
  }
}
