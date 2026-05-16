import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:authproject/config.dart' as config;
import '../models/security_event.dart';

class SecurityServices {
  final String baseUrl = config.baseUrl;

  Future<List<SecurityEvent>> getFailedLoginEvents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/security/failed-logins/'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SecurityEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        jsonDecode(response.body)["detail"] ??
            "Failed to fetch security events",
      );
    }
  }
}
