import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../config.dart' as config;

class AuthService {
  final String baseUrl = config.baseUrl;
  final storage = FlutterSecureStorage();

  // LOGIN
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/auth/login");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['access_token'] != null) {
        await storage.write(key: "access_token", value: data['access_token']);
        await storage.write(key: 'refresh_token', value: data['refresh_token']);
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": data['message'] ?? "Login failed"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  Future<String?> refreshToken() async {
    final refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh_token": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await storage.write(key: 'access_token', value: data['access_token']);
      await storage.write(key: 'refresh_token', value: data['refresh_token']);

      return data['access_token'];
    } else {
      // Refresh failed, force logout
      await logout();
      return null;
    }
  }

  Future<void> logout() async {
    final refreshToken = await storage.read(key: 'refresh_token');

    if (refreshToken != null) {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refresh_token": refreshToken}),
      );
    }

    // Remove tokens locally
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }

  // ACTIVATE ACCOUNT
  Future<Map<String, dynamic>> activateAccount({
    required String token,
    required String password,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/auth/activate");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'token': token, 'password': password}),
      );

      final data = jsonDecode(response.body);

      final success = response.statusCode == 200;
      final message = success
          ? "Activation Successful! Please login."
          : data['message'] ?? "Activation Failed!";

      return {"success": success, "message": message};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // FORGOT PASSWORD
  Future<Map<String, dynamic>> forgetPassword({required String email}) async {
    try {
      final url = Uri.parse("$baseUrl/auth/forgot-password");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final success = response.statusCode == 200;
      final message = success
          ? "Password reset email sent successfully."
          : "Failed to send password reset email.";

      return {"success": success, "message": message};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // RESET PASSWORD
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/auth/reset-password");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token, "new_password": newPassword}),
      );

      final success = response.statusCode == 200;
      final message = success
          ? "Password updated successfully."
          : "Password reset failed.";

      return {"success": success, "message": message};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // GET CURRENT USER
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await storage.read(key: "access_token");
      if (token == null)
        return {"success": false, "message": "No access token"};

      final url = Uri.parse("$baseUrl/auth/me");
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": "Failed to load user data"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
