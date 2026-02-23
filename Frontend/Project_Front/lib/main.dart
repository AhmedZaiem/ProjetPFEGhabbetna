import 'package:authproject/features/Auth/core/auth_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'features/Auth/core/mobile_url_strategy.dart'
    if (dart.library.html) 'features/Auth/core/web_url_strategy.dart';

void main() {
  configureUrlStrategy();

  runApp(MainApp(router: authRouter));
}

class MainApp extends StatefulWidget {
  final GoRouter router;
  const MainApp({super.key, required this.router});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _handleDeepLinks();
  }

  void _handleDeepLinks() async {
    // Handle cold start (app opened via deep link)
    final initialLink = await _appLinks.getInitialAppLink();
    if (initialLink != null) {
      _navigateFromLink(initialLink.toString());
    }

    // Handle links when app is already running
    _appLinks.uriLinkStream.listen((link) {
      if (link != null) _navigateFromLink(link.toString());
    });
  }

  void _navigateFromLink(String link) {
    final uri = Uri.parse(link);
    if (uri.scheme == "ghabbetna" && uri.host == "activate") {
      final token = uri.queryParameters['token'] ?? '';
      if (token.isNotEmpty) {
        widget.router.go('/activate?token=$token');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Ghabbetna",
      routerConfig: widget.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
