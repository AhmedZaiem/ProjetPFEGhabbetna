import 'package:authproject/activation.dart';
import 'package:go_router/go_router.dart';
import 'package:authproject/create_user.dart';
import 'package:authproject/welcome.dart';
import 'package:flutter/material.dart';
import 'login.dart';

import 'core/mobile_url_strategy.dart'
    if (dart.library.html) 'core/web_url_strategy.dart';

void main() {
  configureUrlStrategy();

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => login()),
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
    ],
  );

  runApp(MainApp(router: router));
}

class MainApp extends StatelessWidget {
  final GoRouter router;
  const MainApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Ghabbetna",
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
