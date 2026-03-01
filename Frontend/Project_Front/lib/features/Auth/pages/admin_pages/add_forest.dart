import 'package:flutter/material.dart';

class AddForest extends StatefulWidget {
  const AddForest({super.key});

  @override
  State<AddForest> createState() => _AddForestState();
}

class _AddForestState extends State<AddForest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Forest")),
      body: const Placeholder(),
    );
  }
}
