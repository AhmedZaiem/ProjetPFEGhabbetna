import 'package:authproject/features/Agent/pages/Profile.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:authproject/features/Supervisor/pages/agent_list.dart';
import 'package:authproject/features/Supervisor/pages/incident_list.dart';
import 'package:authproject/features/Supervisor/pages/incident_map.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SupervisorMenu extends StatefulWidget {
  const SupervisorMenu({super.key});

  @override
  State<SupervisorMenu> createState() => _SupervisorMenuState();
}

class _SupervisorMenuState extends State<SupervisorMenu> {
  int _selectedIndex = 0;
  final AuthService authService = AuthService();

  final List<Widget> _contentWidgets = [
    IncidentList(),
    IncidentMap(),
    AgentList(),
    Profile(),
  ];

  void logout() async {
    await authService.logout();
    if (!mounted) return;
    context.go('/');
  }

  NavigationRailDestination _buildItem(String text, IconData icon) {
    return NavigationRailDestination(
      icon: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(icon, size: 18),
          ],
        ),
      ),
      label: const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 240,
              color: Colors.transparent,
              child: Column(
                children: [
                  SizedBox(
                    height: 70,
                    child: Image.asset(
                      'assets/images/logoApp.jpeg',
                      fit: BoxFit.contain,
                    ),
                  ),

                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashFactory: NoSplash.splashFactory,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                      ),
                      child: NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        labelType: NavigationRailLabelType.none,
                        backgroundColor: Colors.transparent,
                        indicatorColor: Colors.transparent,
                        groupAlignment: -1.0,
                        minWidth: 220,
                        destinations: [
                          _buildItem("Incident List", Icons.fireplace),
                          _buildItem("Incident Map", Icons.map),
                          _buildItem("Agent List", Icons.person),
                          _buildItem("Profile", Icons.person_4_sharp),
                        ],
                      ),
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
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            const Color(0xFF1B5E20),
                          ),
                          overlayColor: MaterialStateProperty.all(
                            Colors.transparent,
                          ),
                          shadowColor: MaterialStateProperty.all(
                            Colors.transparent,
                          ),
                          elevation: MaterialStateProperty.all(0),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 14),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const VerticalDivider(thickness: 1, width: 1),

            // Main content
            Expanded(child: Center(child: _contentWidgets[_selectedIndex])),
          ],
        ),
      ),
    );
  }
}
