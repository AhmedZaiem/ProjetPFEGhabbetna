import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:authproject/config.dart' as config;
import '../models/service_model.dart';

class ServiceService {
  final String baseUrl = config.baseUrl;

  Future<List<ServiceModel>> getServices() async {
    final response = await http.get(Uri.parse("$baseUrl/service/services"));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ServiceModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load services");
    }
  }

  Future<ServiceModel> createService({
    required String name,
    required String type,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/service/create_service"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "type": type,
        "description": description,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ServiceModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to create service");
    }
  }

  Future<ServiceModel> updateService(
    int id, {
    String? name,
    String? type,
    String? description,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/service/service_update/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "type": type,
        "description": description,
      }),
    );

    if (response.statusCode == 200) {
      return ServiceModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update service");
    }
  }

  Future<void> deleteService(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/service/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete service");
    }
  }
}
