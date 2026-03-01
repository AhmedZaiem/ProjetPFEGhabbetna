import 'package:authproject/config.dart' as config;
import 'package:authproject/features/Auth/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
  final String baseUrl = config.baseUrl;

  Future<List<UserModel>> fetchUsers() async {
    try {
      var url = Uri.parse("$baseUrl/auth/users");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load users");
      }
    } catch (e) {
      print("Error fetching users: $e");
      throw Exception("Error fetching users");
    }
  }
}
