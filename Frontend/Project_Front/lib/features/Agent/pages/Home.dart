import 'package:flutter/material.dart';
import 'package:authproject/l10n/app_localizations.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return const Placeholder();
  }
}