import 'package:authproject/features/Admin/core/admin_routes.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:authproject/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:app_links/app_links.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/Admin/core/mobile_url_strategy.dart'
    if (dart.library.html) 'features/Admin/core/web_url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();
  runApp(MainApp(key: mainAppKey, router: adminRouter));
}

final GlobalKey<_MainAppState> mainAppKey = GlobalKey<_MainAppState>();

class MainApp extends StatefulWidget {
  final GoRouter router;
  const MainApp({Key? key, required this.router}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final AppLinks _appLinks = AppLinks();
  Locale _locale = const Locale('ar', 'AR');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

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

      locale: _locale,

      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
        Locale('ar', 'AR'),
      ],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        // BACKGROUND COLOR
        scaffoldBackgroundColor: const Color(0xFFDAD7CD),

        primaryColor: const Color(0xFF1B5E20),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          background: const Color(0xFFDAD7CD),
        ),

        // TEXT THEME
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

          // TITLES
          titleLarge: TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
          ),
          titleMedium: TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 16,
            fontFamily: 'Times New Roman',
          ),
          titleSmall: TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 14,
            fontFamily: 'Times New Roman',
          ),
        ),

        // APP BAR
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),

        // BUTTONS
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

        // INPUTS
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(
            color: Colors.black,
            fontFamily: 'Times New Roman',
          ),
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontFamily: 'Times New Roman',
          ),

          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2),
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
