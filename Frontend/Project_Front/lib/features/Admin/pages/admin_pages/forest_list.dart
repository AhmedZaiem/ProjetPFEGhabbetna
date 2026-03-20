import 'package:flutter/material.dart';
import 'package:authproject/features/Admin/models/forest_model.dart';
import 'package:authproject/features/Admin/models/parcelle_model.dart';
import 'package:authproject/features/Admin/services/forest_service.dart';
import 'package:authproject/features/Admin/services/parcelle_service.dart';

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
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Forest List")),
      body: ListView.builder(
        itemCount: forests.length,
        itemBuilder: (_, index) {
          final forest = forests[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ID: ${forest.id}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    forest.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (forest.description != null &&
                      forest.description!.isNotEmpty)
                    Text(
                      forest.description!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    "Area: ${forest.areaHectares} ha",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Risk: ${forest.riskLevel}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => showParcels(forest),
                        child: const Text("View Parcels"),
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
        },
      ),
    );
  }
}
