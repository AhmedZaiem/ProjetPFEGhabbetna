import 'package:authproject/features/Admin/pages/admin_pages/add_polygon.dart';
import 'package:authproject/features/Admin/pages/admin_pages/add_role.dart';
import 'package:authproject/features/Admin/pages/admin_pages/create_user.dart';
import 'package:authproject/features/Admin/pages/admin_pages/forest_list.dart';
import 'package:authproject/features/Admin/pages/admin_pages/user_list.dart';
import 'package:authproject/features/Admin/pages/admin_pages/assign.dart';
import 'package:authproject/features/Admin/pages/admin_pages/assign_agent.dart';
import 'package:authproject/features/Admin/pages/admin_pages/add_service.dart';
import 'package:authproject/features/Admin/pages/admin_pages/manage_incident.dart';
import 'package:authproject/features/Admin/pages/admin_pages/security_page.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:authproject/features/Admin/pages/admin_pages/BI.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:authproject/main.dart';

import 'package:authproject/l10n/app_localizations.dart';

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
    const Bi(),
    const SecurityPage(),
  ];

  void logout() async {
    await authService.logout();
    if (!mounted) return;
    context.go('/');
  }

  void _setLanguage(Locale locale) {
    (mainAppKey.currentState)?.setLocale(locale);
  }

  Widget _langButton(String label, Locale locale) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _setLanguage(locale),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _languageSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              _langButton("EN", const Locale('en', 'US')),
              const SizedBox(width: 6),
              _langButton("FR", const Locale('fr', 'FR')),
              const SizedBox(width: 6),
              _langButton("AR", const Locale('ar', 'AR')),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
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
    final t = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 240,
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 70,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/logoApp.jpeg',
                              height: 150,
                            ),
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
                                _buildItem(t.admin_users_list, Icons.people),
                                _buildItem(t.admin_create_users, Icons.add),
                                _buildItem(
                                  t.admin_manage_roles,
                                  Icons.account_box_sharp,
                                ),
                                _buildItem(
                                  t.admin_assign_supervisor,
                                  Icons.add,
                                ),
                                _buildItem(t.admin_assign_agent, Icons.add),
                                _buildItem(t.admin_add_forests, Icons.forest),
                                _buildItem(
                                  t.admin_forests_list,
                                  Icons.forest_outlined,
                                ),
                                _buildItem(
                                  t.admin_manage_services,
                                  Icons.medical_services,
                                ),
                                _buildItem(
                                  t.admin_manage_incidents,
                                  Icons.add_a_photo_outlined,
                                ),
                                _buildItem(
                                  t.bi,
                                  Icons.stacked_line_chart_outlined,
                                ),
                                _buildItem("Security", Icons.security),
                              ],
                            ),
                          ),
                        ),

                        _languageSelector(),

                        // Logout button
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: logout,
                              icon: const Icon(Icons.logout, size: 16),
                              label: Text(
                                t.logout,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
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
                ),
              ),
            ),

            const VerticalDivider(thickness: 1, width: 1),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Container(
                  key: ValueKey(Localizations.localeOf(context)),
                  child: Center(child: _contentWidgets[_selectedIndex]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
