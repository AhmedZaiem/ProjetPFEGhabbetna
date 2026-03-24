import 'package:authproject/features/Admin/pages/admin_pages/add_polygon.dart';
import 'package:authproject/features/Admin/pages/admin_pages/add_role.dart';
import 'package:authproject/features/Admin/pages/admin_pages/create_user.dart';
import 'package:authproject/features/Admin/pages/admin_pages/forest_list.dart';
import 'package:authproject/features/Admin/pages/admin_pages/user_list.dart';
import 'package:authproject/features/Admin/pages/admin_pages/assign.dart';
import 'package:authproject/features/Admin/pages/admin_pages/add_service.dart';
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
    const ForestList(),
    const Create_User(),
    const AddPolygonPage(),
    const AddRole(),
    const Assign(),
    const AddService(),
  ];

  void logout() async {
    await authService.logout();
    context.replace('/');
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
                    height: 150,
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
                          icon: Icon(Icons.people, size: 25),
                          label: Text(
                            "Users List",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.forest, size: 25),
                          label: Text(
                            "Forest List",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.add, size: 25),
                          label: Text(
                            "Create Users",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.forest_outlined, size: 25),
                          label: Text(
                            "Add Forests",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.manage_accounts, size: 25),
                          label: Text(
                            "Manage Roles",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.add, size: 25),
                          label: Text(
                            "Assign User",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.add, size: 25),
                          label: Text(
                            "Add Service",
                            style: TextStyle(fontSize: 14),
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
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text(
                          "Logout",
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
