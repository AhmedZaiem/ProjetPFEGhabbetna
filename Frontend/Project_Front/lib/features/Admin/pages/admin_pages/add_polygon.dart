import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

import 'package:authproject/features/Admin/models/coordinates.dart';
import 'package:authproject/features/Admin/models/forest_model.dart';
import 'package:authproject/features/Admin/models/parcelle_model.dart';
import 'package:authproject/features/Admin/services/forest_service.dart';
import 'package:authproject/features/Admin/services/parcelle_service.dart';

import 'package:authproject/l10n/app_localizations.dart';

enum PolygonMode { forest, parcel }

class AddPolygonPage extends StatefulWidget {
  const AddPolygonPage({super.key});

  @override
  State<AddPolygonPage> createState() => _AddPolygonPageState();
}

class _AddPolygonPageState extends State<AddPolygonPage> {
  PolygonMode mode = PolygonMode.forest;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController regionController = TextEditingController();

  final MapController mapController = MapController();

  final List<LatLng> points = [];

  final ForestService forestService = ForestService();
  final ParcelService parcelService = ParcelService();

  List<Forest> forests = [];
  List<Parcel> parcels = [];

  @override
  void initState() {
    super.initState();
    loadPolygons();
  }

  void addPoint(LatLng point) {
    setState(() {
      points.add(point);

      if (points.length >= 3) {
        final centerLat =
            points.map((p) => p.latitude).reduce((a, b) => a + b) /
            points.length;
        final centerLng =
            points.map((p) => p.longitude).reduce((a, b) => a + b) /
            points.length;

        points.sort((a, b) {
          final angleA = atan2(a.latitude - centerLat, a.longitude - centerLng);
          final angleB = atan2(b.latitude - centerLat, b.longitude - centerLng);
          return angleA.compareTo(angleB);
        });
      }
    });
  }

  void clearPolygon() {
    setState(() {
      points.clear();
    });
  }

  void undoPoint() {
    if (points.isNotEmpty) {
      setState(() {
        points.removeLast();
      });
    }
  }

  Future<void> loadPolygons() async {
    try {
      final fetchedForests = await forestService.getForests();
      final fetchedParcels = await parcelService.getParcels();

      setState(() {
        forests = fetchedForests;
        parcels = fetchedParcels;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> savePolygon() async {
    final t = AppLocalizations.of(context)!;
    if (points.length < 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.error_polygon_min_points)));
      return;
    }

    List<Coordinates> coords = points
        .map((p) => Coordinates(lng: p.longitude, lat: p.latitude))
        .toList();

    try {
      if (mode == PolygonMode.forest) {
        await forestService.createForest(
          ForestCreate(
            name: nameController.text,
            description: descriptionController.text,
            region: regionController.text,
            boundary: coords,
          ),
        );
      } else {
        await parcelService.createParcel(
          ParcelCreate(
            name: nameController.text,
            boundary: coords,
            region: regionController.text,
          ),
        );
      }

      /// success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mode == PolygonMode.forest
                ? t.success_forest_created
                : t.success_parcel_created,
          ),
        ),
      );

      nameController.clear();
      descriptionController.clear();
      regionController.clear();

      clearPolygon();

      await loadPolygons();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  final northTunisiaBounds = LatLngBounds(
    LatLng(36.5, 9.5),
    LatLng(37.4, 10.8),
  );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logoApp.jpeg', height: 80),
            const SizedBox(width: 12),
            Text(t.admin_forest_parcel),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            /// Mode Toggle
            ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              isSelected: [
                mode == PolygonMode.forest,
                mode == PolygonMode.parcel,
              ],
              onPressed: (index) {
                setState(() {
                  mode = index == 0 ? PolygonMode.forest : PolygonMode.parcel;
                });
              },
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                  child: Text(
                    t.admin_forest,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                  child: Text(
                    t.admin_parcel,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Name and Description Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: mode == PolygonMode.forest
                          ? t.admin_forest_name
                          : t.admin_parcel_name,
                      prefixIcon: Icon(
                        mode == PolygonMode.forest ? Icons.forest : Icons.map,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: regionController,
                    decoration: InputDecoration(
                      labelText: mode == PolygonMode.forest
                          ? t.admin_forest_region
                          : t.admin_parcel_region,
                      prefixIcon: Icon(
                        mode == PolygonMode.forest ? Icons.forest : Icons.map,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (mode == PolygonMode.forest)
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: t.admin_description,
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// Map and Buttons side by side
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Buttons Section (Left)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.undo),
                        label: Text(t.admin_undo),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: undoPoint,
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.clear),
                        label: Text(t.admin_clear),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: clearPolygon,
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: Text(t.admin_save),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: savePolygon,
                      ),
                      const SizedBox(height: 20),

                      /// Zoom Buttons
                      FloatingActionButton(
                        heroTag: "zoomIn",
                        mini: true,
                        backgroundColor: Colors.green,
                        onPressed: () {
                          mapController.move(
                            mapController.camera.center,
                            mapController.camera.zoom + 1,
                          );
                        },
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: "zoomOut",
                        mini: true,
                        backgroundColor: Colors.red,
                        onPressed: () {
                          mapController.move(
                            mapController.camera.center,
                            mapController.camera.zoom - 1,
                          );
                        },
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),

                  const SizedBox(width: 15),

                  /// Map Section (Right)
                  Expanded(
                    flex: 3,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCameraFit: CameraFit.bounds(
                            bounds: northTunisiaBounds,
                            padding: EdgeInsets.all(16),
                          ),
                          cameraConstraint: CameraConstraint.contain(
                            bounds: northTunisiaBounds,
                          ),
                          minZoom: 8.5,
                          maxZoom: 18,
                          initialCenter: LatLng(37.2, 10.12),
                          initialZoom: 13,
                          onTap: (tapPosition, point) => addPoint(point),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          ),

                          /// Currently drawn polygon (light blue)
                          if (points.length >= 3)
                            PolygonLayer(
                              polygons: [
                                Polygon(
                                  points: points,
                                  color: Colors.lightBlue.withOpacity(0.3),
                                  borderColor: Colors.blue,
                                  borderStrokeWidth: 3,
                                ),
                              ],
                            ),

                          /// Points markers
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

                          /// Existing forests
                          PolygonLayer(
                            polygons: forests.map((forest) {
                              return Polygon(
                                points: forest.boundary
                                    .map((c) => LatLng(c.lat, c.lng))
                                    .toList(),
                                color: Colors.green.withOpacity(0.2),
                                borderColor: Colors.green,
                                borderStrokeWidth: 2,
                              );
                            }).toList(),
                          ),

                          /// Existing parcels
                          PolygonLayer(
                            polygons: parcels.map((parcel) {
                              return Polygon(
                                points: parcel.boundary
                                    .map((c) => LatLng(c.lat, c.lng))
                                    .toList(),
                                color: Colors.orange.withOpacity(0.3),
                                borderColor: Colors.orange,
                                borderStrokeWidth: 2,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
