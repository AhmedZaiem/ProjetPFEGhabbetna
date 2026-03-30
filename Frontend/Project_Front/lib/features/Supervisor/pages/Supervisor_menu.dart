import 'package:authproject/features/Admin/pages/admin_pages/assign.dart';
import 'package:authproject/features/Admin/pages/admin_pages/assign_agent.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:authproject/features/Supervisor/pages/incident_list.dart';
import 'package:authproject/features/Supervisor/pages/incident_map.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SupervisorMenu extends StatefulWidget {
  const SupervisorMenu({super.key});

  @override
  State<SupervisorMenu> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SupervisorMenu> {
  int _selectedIndex = 0;

  final AuthService authService = AuthService();

  final List<Widget> _contentWidgets = [
    IncidentList(),
    IncidentMap(),
    AssignAgent(),
  ];

  void logout() async {
    await authService.logout();
    if (!mounted) return;

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Row(
          children: [
            Container(
              width: 220,
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: Image.asset(
                      'assets/images/logoApp.jpeg',
                      fit: BoxFit.contain,
                    ),
                  ),

                  Expanded(
                    child: NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      labelType: NavigationRailLabelType.all,
                      backgroundColor: Colors.transparent,
                      minWidth: 80,
                      minExtendedWidth: 200,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.fireplace, size: 20),
                          label: Text(
                            "Incident List",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.map, size: 20),
                          label: Text(
                            "Incident Map",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.add, size: 20),
                          label: Text(
                            "Assign Agent",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: logout,
                        icon: const Icon(Icons.logout, size: 16),
                        label: const Text(
                          "Logout",
                          style: TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const VerticalDivider(thickness: 1, width: 1),

            Expanded(child: Center(child: _contentWidgets[_selectedIndex])),
          ],
        ),
      ),
    );
  }
}
