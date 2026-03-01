import 'package:flutter/material.dart';

class ForestList extends StatefulWidget {
  const ForestList({super.key});

  @override
  State<ForestList> createState() => _ForestListState();
}

class _ForestListState extends State<ForestList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forest List")),
      body: const Placeholder(),
    );
  }
}
