import 'package:authproject/features/Auth/pages/activation.dart';
import 'package:authproject/features/Admin/pages/admin_pages/admin_dashboard.dart';
import 'dart:async';
import 'package:authproject/features/Auth/pages/forgot_password.dart';
import 'package:authproject/features/Auth/pages/login.dart';
import 'package:authproject/features/Auth/pages/reset_password.dart';
import 'package:authproject/features/Agent/pages/welcome.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final authService = AuthService();

final adminRouter = GoRouter(
  redirect: (context, state) async {
    print("➡️ Redirect check: ${state.uri}");

    // 🔥 FORCE allow activation route
    if (state.uri.toString().contains('/activate') ||
        state.uri.toString().contains('/reset-password')) {
      return null;
    }
    final path = state.uri.path;

    // Public routes (no auth needed)
    if (path == '/' ||
        path.startsWith('/forgot_password') ||
        path.startsWith('/activate') ||
        path.startsWith('/reset-password')) {
      return null;
    }

    String? accessToken = await authService.getAccessToken();

    if (accessToken == null || JwtDecoder.isExpired(accessToken)) {
      // Try refresh
      accessToken = await authService.refreshToken();
      if (accessToken == null) return '/'; // can't refresh → go to login
    }

    final payload = JwtDecoder.decode(accessToken);
    final role = payload['role_id'];

    if (role == 1 && path.startsWith('/admin_dashboard')) return null;
    if (role == 3 && path.startsWith('/welcome')) return null;

    // Redirect based on role
    if (role == 1) return '/admin_dashboard';
    if (role == 3) return '/welcome';

    // Unauthorized → fallback
    return '/';
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => login()),
    GoRoute(path: '/welcome', builder: (context, state) => Welcome()),

    GoRoute(
      path: '/forgot_password',
      builder: (context, state) => ForgetPassword(),
    ),
    GoRoute(
      path: '/activate',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'] ?? '';
        if (token.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("Invalid activation link")),
          );
        }
        return Activation(token: token);
      },
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'] ?? '';
        if (token == null || token.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("Invalid reset password link")),
          );
        }
        return ResetPassword(token: token);
      },
    ),
    GoRoute(
      path: '/admin_dashboard',
      builder: (context, state) => AdminDashboard(),
    ),
  ],
);
