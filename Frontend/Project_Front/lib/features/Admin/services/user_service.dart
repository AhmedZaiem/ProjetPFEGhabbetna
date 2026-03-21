import 'package:authproject/config.dart' as config;
import 'package:authproject/features/Admin/models/user_model.dart';
import 'package:authproject/features/Admin/models/role_model.dart';
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

  Future<Map<String, dynamic>> createUser({
    required String username,
    required String email,
    required int age,
    required String roleName,
  }) async {
    try {
      var url = Uri.parse("$baseUrl/auth/register");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'username': username,
          'email': email,
          'age': age,
          'role_name': roleName,
        }),
      );

      final data = jsonDecode(response.body);
      final message =
          (data['message'] as String?) ??
          "Registration failed. Please check your input.";

      final bool success;
      if (data.containsKey('success')) {
        success = data['success'] == true;
      } else {
        success =
            message.toLowerCase().contains("created") ||
            message.toLowerCase().contains("success");
      }

      return {"success": success, "message": message};
    } catch (e) {
      return {"success": false, "message": "An error occurred: $e"};
    }
  }

  Future<void> blockUser(int userId) async {
    try {
      var url = Uri.parse("$baseUrl/auth/users/$userId/block");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        print("User $userId blocked successfully");
      } else if (response.statusCode == 404) {
        throw Exception("User not found");
      } else {
        throw Exception(
          "Failed to block user: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("Error blocking user: $e");
      throw Exception("Error blocking user: $e");
    }
  }

  Future<void> unblockUser(int userId) async {
    try {
      var url = Uri.parse("$baseUrl/auth/users/$userId/unblock");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        print("User $userId unblocked successfully");
      } else if (response.statusCode == 404) {
        throw Exception("User not found");
      } else {
        throw Exception(
          "Failed to unblock user: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("Error unblocking user: $e");
      throw Exception("Error unblocking user: $e");
    }
  }

  Future<void> createRole(String name) async {
    try {
      var url = Uri.parse("$baseUrl/auth/create-role");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Role created successfully");
      } else if (response.statusCode == 400) {
        throw Exception("Role already exists");
      } else {
        throw Exception(
          "Failed to create role: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("Error creating role: $e");
      throw Exception("Error creating role: $e");
    }
  }

  Future<List<RoleModel>> getRoles() async {
    try {
      var url = Uri.parse("$baseUrl/auth/roles");

      var response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RoleModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load roles");
      }
    } catch (e) {
      print("Error fetching roles: $e");
      throw Exception("Error fetching roles: $e");
    }
  }

  Future<void> deleteRole(String name) async {
    final url = Uri.parse("$baseUrl/auth/delete-role?name=$name");
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to delete role: ${response.statusCode} - ${response.body}",
      );
    } else {
      print("Role deleted successfully");
    }
  }

  Future<void> modifyRole(String oldName, String newName) async {
    try {
      var url = Uri.parse("$baseUrl/auth/modify-role");

      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"old_name": oldName, "new_name": newName}),
      );

      if (response.statusCode == 200) {
        print("Role modified successfully");
      } else if (response.statusCode == 404) {
        throw Exception("Original role not found");
      } else if (response.statusCode == 400) {
        throw Exception("New role name already exists");
      } else {
        throw Exception(
          "Failed to modify role: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("Error modifying role: $e");
      throw Exception("Error modifying role: $e");
    }
  }

  Future<List<UserModel>> getUnassignedAgents() async {
    try {
      var url = Uri.parse("$baseUrl/auth/agents/unassigned");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load users");
      }
    } catch (e) {
      print("Error fetching unassigned agents: $e");
      throw Exception("Error fetching unassigned agents");
    }
  }
}
