import 'package:authproject/features/Admin/core/admin_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'features/Admin/core/mobile_url_strategy.dart'
    if (dart.library.html) 'features/Admin/core/web_url_strategy.dart';

void main() {
  configureUrlStrategy();

  runApp(MainApp(router: adminRouter));
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
      title: "Ghabetna",
      routerConfig: widget.router,
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF2EFEA),

        primaryColor: const Color(0xFF1B5E20),

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 14, 43, 16),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
