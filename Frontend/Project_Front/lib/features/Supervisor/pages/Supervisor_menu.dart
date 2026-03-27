import 'package:flutter/material.dart';

class SupervisorMenu extends StatefulWidget {
  const SupervisorMenu({super.key});

  @override
  State<SupervisorMenu> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SupervisorMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [Text("Supervisor Space")]));
  }
}
