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
                            Text(
                              "${t.admin_area}: ${parcel.areaHectares.floorToDouble()} ha",
                            ),
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

  void showForestDialog(Forest forest) {
    final points = forest.boundary.map((c) => LatLng(c.lat, c.lng)).toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(forest.name),

        content: SizedBox(
          width: 500,
          height: 300,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: points.isNotEmpty
                  ? points.first
                  : const LatLng(36.8, 10.1),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
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
                markers: points
                    .map(
                      (p) => Marker(
                        point: p,
                        width: 25,
                        height: 25,
                        child: const Icon(Icons.location_on, color: Colors.red),
                      ),
                    )
                    .toList(),
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: const Color(0xFF1B4332),

        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/logoApp.jpeg', height: 38),
            ),
            const SizedBox(width: 12),
            Text(
              t.admin_forests_list,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTopCard(
                      t.admin_total_forests,
                      forests.length.toString(),
                      Icons.forest,
                      const Color(0xFF1B4332),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTopCard(
                      t.admin_total_parcels,
                      parcels.length.toString(),
                      Icons.map,
                      const Color(0xFF1B4332),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: forests.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 1.55,
                ),
                itemBuilder: (context, index) {
                  return _buildForestCard(forests[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),

        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: [
          Icon(icon, size: 38, color: Colors.white),

          const SizedBox(height: 12),

          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForestCard(Forest forest) {
    final t = AppLocalizations.of(context)!;

    final points = forest.boundary.map((c) => LatLng(c.lat, c.lng)).toList();

    return SizedBox(
      height: 360,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.forest,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      forest.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// MAP
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: points.isNotEmpty
                            ? points.first
                            : const LatLng(36.8, 10.1),
                        initialZoom: 12.5,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'com.example.app',
                        ),

                        PolygonLayer(
                          polygons: [
                            Polygon(
                              points: points,
                              color: Colors.lightGreen.withOpacity(0.35),
                              borderColor: Colors.lightGreenAccent,
                              borderStrokeWidth: 4,
                            ),
                          ],
                        ),

                        MarkerLayer(
                          markers: points
                              .map(
                                (p) => Marker(
                                  point: p,
                                  width: 26,
                                  height: 26,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// INFO
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_city,
                            color: Colors.white70,
                            size: 16,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              forest.region,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${forest.areaHectares.floor()} ha",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// BUTTONS
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      onPressed: () => deleteForest(forest.id),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => showUpdateForestDialog(forest.id),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => showParcels(forest),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        t.admin_view_parcels,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}