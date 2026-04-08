import 'package:authproject/features/Admin/pages/admin_pages/add_polygon.dart';
import 'package:authproject/features/Admin/pages/admin_pages/add_role.dart';
import 'package:authproject/features/Admin/pages/admin_pages/create_user.dart';
import 'package:authproject/features/Admin/pages/admin_pages/forest_list.dart';
import 'package:authproject/features/Admin/pages/admin_pages/user_list.dart';
import 'package:authproject/features/Admin/pages/admin_pages/assign.dart';
import 'package:authproject/features/Admin/pages/admin_pages/assign_agent.dart';
import 'package:authproject/features/Admin/pages/admin_pages/add_service.dart';
import 'package:authproject/features/Admin/pages/admin_pages/manage_incident.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final AuthService authService = AuthService();

  final List<Widget> _contentWidgets = [
    UserList(),
    const Create_User(),
    const AddRole(),
    const Assign(),
    const AssignAgent(),
    const AddPolygonPage(),
    const ForestList(),
    const AddService(),
    const ManageIncident(),
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
              color: Colors.transparent, // transparent background
              child: Column(
                children: [
                  // Logo
                  SizedBox(
                    height: 70,
                    child: Image.asset(
                      'assets/images/logoApp.jpeg',
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Navigation Rail without Theme wrapper
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
                          _buildItem("Users List", Icons.people),
                          _buildItem("Create Users", Icons.add),
                          _buildItem("Manage Roles", Icons.account_box_sharp),
                          _buildItem("Assign Supervisor", Icons.add),
                          _buildItem("Assign Agent", Icons.add),
                          _buildItem("Add Forests", Icons.forest),
                          _buildItem("Forests list", Icons.forest_outlined),
                          _buildItem("Manage Services", Icons.medical_services),
                          _buildItem(
                            "Manage Incidents",
                            Icons.add_a_photo_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Logout button
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
                            Colors.red,
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
