import 'package:flutter/material.dart';
import 'Profile.dart';
import 'upload.dart';
import 'Home.dart';
import 'History.dart';

import 'package:authproject/l10n/app_localizations.dart';
import 'package:authproject/main.dart';

class agentDashboard extends StatefulWidget {
  const agentDashboard({super.key});

  @override
  State<agentDashboard> createState() => _agentDashboardState();
}

class _agentDashboardState extends State<agentDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [Upload(), Profile(), Home(), History()];

  void _setLanguage(Locale locale) {
    (mainAppKey.currentState)?.setLocale(locale);
  }

  Widget _langButton(String label, Locale locale) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _setLanguage(locale),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _languageSwitcher() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          _langButton("EN", const Locale('en', 'US')),
          const SizedBox(width: 6),
          _langButton("FR", const Locale('fr', 'FR')),
          const SizedBox(width: 6),
          _langButton("AR", const Locale('ar', 'AR')),
        ],
      ),
    );
  }

   @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.upload),
                label: t.agent_upload,
                backgroundColor: const Color(0xFF4CAF50),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: t.supervisor_profile,
                backgroundColor: const Color(0xFF4CAF50),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_filled),
                label: t.agent_home,
                backgroundColor: const Color(0xFF4CAF50),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history),
                label: t.agent_history,
                backgroundColor: const Color(0xFF4CAF50),
              ),
            ],
          ),

          _languageSwitcher(),
        ],
      ),
    );
  }
}
