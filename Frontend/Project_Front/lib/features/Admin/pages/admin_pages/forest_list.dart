import 'package:flutter/material.dart';
import 'package:authproject/features/Admin/models/forest_model.dart';
import 'package:authproject/features/Admin/models/parcelle_model.dart';
import 'package:authproject/features/Admin/services/forest_service.dart';
import 'package:authproject/features/Admin/services/parcelle_service.dart';

import 'package:authproject/l10n/app_localizations.dart';

class ForestList extends StatefulWidget {
  const ForestList({super.key});

  @override
  State<ForestList> createState() => _ForestListState();
}

class _ForestListState extends State<ForestList> {
  final ForestService forestService = ForestService();
  final ParcelService parcelService = ParcelService();

  List<Forest> forests = [];
  List<Parcel> parcels = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    try {
      final fetchedForests = await forestService.getForests();
      final fetchedParcels = await parcelService.getParcels();
      setState(() {
        forests = fetchedForests;
        parcels = fetchedParcels;
        loading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() => loading = false);
    }
  }

  Future<void> deleteParcel(int id) async {
    try {
      await parcelService.deleteParcel(id);
      await loadData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Parcel deleted")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void showParcels(Forest forest) {
    final relatedParcels = parcels
        .where((p) => p.forestId == forest.id)
        .toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Parcels of ${forest.name}"),
        content: SizedBox(
          width: 400,
          child: relatedParcels.isEmpty
              ? const Text("No parcels found")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: relatedParcels.length,
                  itemBuilder: (_, index) {
                    final parcel = relatedParcels[index];
                    return ListTile(
                      title: Text(parcel.name),
                      subtitle: Text("Area: ${parcel.areaHectares} ha"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteParcel(parcel.id),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> deleteForest(int id) async {
    try {
      await forestService.deleteForest(id);
      await loadData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Forest deleted")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logoApp.jpeg',
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Text(t.admin_forests_list),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTopCard(
                  t.admin_total_forests,
                  forests.length.toString(),
                  Icons.forest,
                ),
                const SizedBox(width: 12),
                _buildTopCard(
                  t.admin_total_parcels,
                  parcels.length.toString(),
                  Icons.map,
                ),
                const SizedBox(width: 12),
                _buildTopCard("Another Stat", "-", Icons.dashboard),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...forests.map((forest) => _buildForestCard(forest)).toList(),
        ],
      ),
    );
  }

  Widget _buildTopCard(String title, String count, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Icon(icon, size: 36, color: Colors.black),
              const SizedBox(height: 8),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForestCard(Forest forest) {
    final t = AppLocalizations.of(context)!;

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              forest.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            if (forest.description != null && forest.description!.isNotEmpty)
              Text(
                forest.description!,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            const SizedBox(height: 6),
            Text(
              "Area: ${forest.areaHectares} ha",
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              "Risk: ${forest.riskLevel}",
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => showParcels(forest),
                  icon: const Icon(Icons.view_list),
                  label: Text(t.admin_view_parcels),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteForest(forest.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
