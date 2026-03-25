import 'package:authproject/features/Admin/core/admin_routes.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:app_links/app_links.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'features/Admin/core/mobile_url_strategy.dart'
    if (dart.library.html) 'features/Admin/core/web_url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        scaffoldBackgroundColor: const Color(0xFFE8F8F0),

        primaryColor: const Color.fromARGB(255, 19, 113, 58),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 21, 121, 63),
          background: const Color(0xFFF4FBF7),
        ),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Times New Roman',
          ),
          bodyMedium: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Times New Roman',
          ),
          bodySmall: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: 'Times New Roman',
          ),

          titleLarge: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
          ),
          titleMedium: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Times New Roman',
          ),
          titleSmall: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Times New Roman',
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2ECC71),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2ECC71),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(
            color: Colors.black,
            fontFamily: 'Georgia',
          ),
          hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'Georgia'),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 25, 126, 67),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
