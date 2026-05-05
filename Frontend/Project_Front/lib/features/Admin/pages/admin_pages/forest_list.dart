import 'package:flutter/material.dart';
import 'dart:math';
import 'package:authproject/features/Admin/models/forest_model.dart';
import 'package:authproject/features/Admin/models/parcelle_model.dart';
import 'package:authproject/features/Admin/services/forest_service.dart';
import 'package:authproject/features/Admin/services/parcelle_service.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:authproject/features/Admin/models/coordinates.dart';

import 'package:authproject/l10n/app_localizations.dart';

class ForestList extends StatefulWidget {
  const ForestList({super.key});

  @override
  State<ForestList> createState() => _ForestListState();
}

class _ForestListState extends State<ForestList> {
  final ForestService forestService = ForestService();
  final ParcelService parcelService = ParcelService();

  final List<String> tunisianStates = [
    "Tunis",
    "Ariana",
    "BenArous",
    "Manouba",
    "Nabeul",
    "Zaghouan",
    "Bizerte",
    "Béja",
    "Jendouba",
    "Kef",
    "Siliana",
    "Sousse",
    "Monastir",
    "Mahdia",
    "Sfax",
    "Kairouan",
    "Kasserine",
    "SidiBouzid",
    "Gabès",
    "Medenine",
    "Tataouine",
    "Gafsa",
    "Tozeur",
    "Kebili",
  ];

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

  void sortPolygonPoints(List<LatLng> points) {
    if (points.length < 3) return;

    final centerLat =
        points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;

    final centerLng =
        points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;

    points.sort((a, b) {
      final angleA = atan2(a.latitude - centerLat, a.longitude - centerLng);
      final angleB = atan2(b.latitude - centerLat, b.longitude - centerLng);
      return angleA.compareTo(angleB);
    });
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
    final t = AppLocalizations.of(context)!;

    final relatedParcels = parcels
        .where((p) => p.forestId == forest.id)
        .toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        title: Row(
          children: [
            const Icon(Icons.map, color: Color.fromARGB(255, 0, 0, 0)),
            const SizedBox(width: 8),
            Expanded(child: Text("Parcels of ${forest.name}")),
          ],
        ),

        content: SizedBox(
          width: 420,
          child: relatedParcels.isEmpty
              ? Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 8),
                    Text("No parcels found"),
                  ],
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: relatedParcels.length,
                  itemBuilder: (_, index) {
                    final parcel = relatedParcels[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.landscape,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),

                        title: Text(
                          parcel.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        subtitle: Row(
                          children: [
                            const Icon(
                              Icons.straighten,
                              size: 16,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 4),
                            Text("${t.admin_area}: ${parcel.areaHectares} ha"),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  showUpdateParcelleDialog(parcel.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteParcel(parcel.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: Text(t.close),
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

  Future<void> showUpdateForestDialog(int forestId) async {
    final forest = await forestService.getForestById(forestId);

    final t = AppLocalizations.of(context)!;

    final nameController = TextEditingController(text: forest.name);
    final descController = TextEditingController(
      text: forest.description ?? "",
    );
    final regionController = TextEditingController(text: forest.region);

    List<LatLng> points = forest.boundary
        .map((c) => LatLng(c.lat, c.lng))
        .toList();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(t.admin_update),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: t.admin_forest_name,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: t.admin_description,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: regionController,
                      decoration: InputDecoration(labelText: t.admin_region),
                    ),

                    const SizedBox(height: 10),

                    /// MAP
                    SizedBox(
                      height: 300,
                      child: Column(
                        children: [
                          Expanded(
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: points.isNotEmpty
                                    ? points.first
                                    : const LatLng(36.8, 10.1),
                                initialZoom: 13,
                                onTap: (_, p) {
                                  setStateDialog(() {
                                    points.add(p);
                                    sortPolygonPoints(points);
                                  });
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                ),

                                PolygonLayer(
                                  polygons: [
                                    Polygon(
                                      points: points,
                                      color: Colors.green.withOpacity(0.3),
                                      borderColor: Colors.green,
                                      borderStrokeWidth: 3,
                                    ),
                                  ],
                                ),

                                MarkerLayer(
                                  markers: points.map((p) {
                                    return Marker(
                                      point: p,
                                      width: 30,
                                      height: 30,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  setStateDialog(() {
                                    if (points.isNotEmpty) {
                                      points.removeLast();
                                    }
                                  });
                                },
                                icon: const Icon(Icons.undo),
                                label: Text(t.admin_undo),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade700,
                                  foregroundColor: Colors.white,
                                ),
                              ),

                              ElevatedButton.icon(
                                onPressed: () {
                                  setStateDialog(() {
                                    points.clear();
                                  });
                                },
                                icon: const Icon(Icons.clear),
                                label: Text(t.admin_clear),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t.admin_cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await forestService.updateForest(
                      forest.id,
                      ForestCreate(
                        name: nameController.text,
                        description: descController.text,
                        region: regionController.text,
                        boundary: points
                            .map(
                              (p) => Coordinates(
                                lng: p.longitude,
                                lat: p.latitude,
                              ),
                            )
                            .toList(),
                      ),
                    );

                    Navigator.pop(context);
                    await loadData();

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(t.admin_update)));
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
                child: Text(t.admin_update),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> showUpdateParcelleDialog(int parcelleId) async {
    final t = AppLocalizations.of(context)!;

    final parcel = await parcelService.getParcelById(parcelleId);

    final nameController = TextEditingController(text: parcel.name);
    final regionController = TextEditingController(text: parcel.region);

    List<LatLng> points = parcel.boundary
        .map((c) => LatLng(c.lat, c.lng))
        .toList();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(t.admin_update),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: t.admin_parcel_name,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: regionController,
                      decoration: InputDecoration(
                        labelText: t.admin_parcel_region,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// MAP
                    SizedBox(
                      height: 300,
                      child: Column(
                        children: [
                          Expanded(
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: points.isNotEmpty
                                    ? points.first
                                    : const LatLng(36.8, 10.1),
                                initialZoom: 13,
                                onTap: (_, p) {
                                  setStateDialog(() {
                                    points.add(p);
                                    sortPolygonPoints(points);
                                  });
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                ),

                                PolygonLayer(
                                  polygons: [
                                    Polygon(
                                      points: points,
                                      color: Colors.orange.withOpacity(0.3),
                                      borderColor: Colors.orange,
                                      borderStrokeWidth: 3,
                                    ),
                                  ],
                                ),

                                MarkerLayer(
                                  markers: points.map((p) {
                                    return Marker(
                                      point: p,
                                      width: 30,
                                      height: 30,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  setStateDialog(() {
                                    if (points.isNotEmpty) {
                                      points.removeLast();
                                    }
                                  });
                                },
                                icon: const Icon(Icons.undo),
                                label: Text(t.admin_undo),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade700,
                                  foregroundColor: Colors.white,
                                ),
                              ),

                              ElevatedButton.icon(
                                onPressed: () {
                                  setStateDialog(() {
                                    points.clear();
                                  });
                                },
                                icon: const Icon(Icons.clear),
                                label: Text(t.admin_clear),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t.admin_cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await parcelService.updateParcel(
                      parcel.id,
                      ParcelCreate(
                        name: nameController.text,
                        region: regionController.text,
                        boundary: points
                            .map(
                              (p) => Coordinates(
                                lng: p.longitude,
                                lat: p.latitude,
                              ),
                            )
                            .toList(),
                      ),
                    );

                    // close UPDATE dialog
                    Navigator.pop(context);

                    // close PARCELS dialog
                    Navigator.pop(context);

                    await loadData();

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(t.admin_update)));
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
                child: Text(t.admin_update),
              ),
            ],
          );
        },
      ),
    );
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/images/logoApp.jpeg', height: 36),
            ),
            const SizedBox(width: 12),
            Text(
              t.admin_forests_list,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
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
            Row(
              children: [
                const Icon(
                  Icons.park,
                  color: Color.fromARGB(255, 0, 0, 0),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${t.admin_name} : ${forest.name}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (forest.description != null && forest.description!.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.description, color: Colors.grey, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${t.admin_description} : ${forest.description!}",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  "${t.admin_region} : ${forest.region}",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.straighten, color: Colors.blueGrey, size: 18),
                const SizedBox(width: 6),
                Text(
                  "${t.admin_area} : ${forest.areaHectares} ha",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color.fromARGB(255, 67, 51, 28),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  "${t.admin_risk} : ${forest.riskLevel}",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => showParcels(forest),
                  icon: const Icon(Icons.view_list),
                  label: Text(t.admin_view_parcels),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
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
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => showUpdateForestDialog(forest.id),
                ),

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
