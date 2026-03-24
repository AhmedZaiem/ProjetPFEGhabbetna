import 'package:flutter/material.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Row(
        children: [
          Image.asset('assets/images/logoApp.jpeg', height: 80),
          const SizedBox(width: 12),
          const Text("Add Services"),
        ],
      ),
    ),
    body: const Center(
      child: Text("Add Service Page Content Here"),
    ),
  );
}
}