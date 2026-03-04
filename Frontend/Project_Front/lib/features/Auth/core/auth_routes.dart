import 'package:authproject/features/Auth/pages/activation.dart';
import 'package:authproject/features/Auth/pages/admin_pages/admin_dashboard.dart';

import 'package:authproject/features/Auth/pages/forgot_password.dart';
import 'package:authproject/features/Auth/pages/login.dart';
import 'package:authproject/features/Auth/pages/reset_password.dart';
import 'package:authproject/features/Auth/pages/welcome.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final authRouter = GoRouter(
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
        if (token == null || token.isEmpty) {
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
