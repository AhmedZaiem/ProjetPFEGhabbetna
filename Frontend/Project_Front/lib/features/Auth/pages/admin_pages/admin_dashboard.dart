import 'package:authproject/features/Auth/pages/admin_pages/add_forest.dart';
import 'package:authproject/features/Auth/pages/admin_pages/add_role.dart';
import 'package:authproject/features/Auth/pages/admin_pages/create_user.dart';
import 'package:authproject/features/Auth/pages/admin_pages/forest_list.dart';
import 'package:authproject/features/Auth/pages/admin_pages/user_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;


  final List<Widget> _contentWidgets = [
    UserList(),
    const ForestList(), 
    const Create_User(), 
    const AddForest(), 
    const AddRole(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // NavigationRail on the left
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
              // Handle navigation / actions
              switch (index) {
                case 0:
                  _selectedIndex = 0;
                  break;
                case 1:
                  _selectedIndex = 1;
                  break;
                case 2:
                  _selectedIndex = 2;
                  break;
                case 3:
                  _selectedIndex = 3;
                  break;
                case 4:
                  _selectedIndex = 4;
                  break;
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text("Users List"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.forest),
                label: Text("Forest List"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add),
                label: Text("Create Users"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add),
                label: Text("Add Forests"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add),
                label: Text("Add Roles"),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main content area
          Expanded(child: Center(child: _contentWidgets[_selectedIndex])),
        ],
      ),
    );
  }
}
