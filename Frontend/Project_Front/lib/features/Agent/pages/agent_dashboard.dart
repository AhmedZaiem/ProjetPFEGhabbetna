import 'package:flutter/material.dart';
import 'Profile.dart';
import 'upload.dart';
import 'Home.dart';
import 'History.dart';

class agentDashboard extends StatefulWidget {
  const agentDashboard({super.key});

  @override
  State<agentDashboard> createState() => _agentDashboardState();
}

class _agentDashboardState extends State<agentDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Upload(), 
    Profile(),
    Home(),
    History(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: "Upload"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }
}
