import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:authproject/features/Admin/models/coordinates.dart';
import 'package:authproject/features/Admin/models/forest_model.dart';
import 'package:authproject/features/Admin/models/parcelle_model.dart';
import 'package:authproject/features/Admin/services/forest_service.dart';
import 'package:authproject/features/Admin/services/parcelle_service.dart';

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
    if (points.length < 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Need at least 3 points")));
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
            boundary: coords,
          ),
        );
      } else {
        await parcelService.createParcel(
          ParcelCreate(name: nameController.text, boundary: coords),
        );
      }

      /// success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mode == PolygonMode.forest
                ? "Forest added successfully"
                : "Parcel added successfully",
          ),
        ),
      );

      nameController.clear();
      descriptionController.clear();

      clearPolygon();

      await loadPolygons();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logoApp.jpeg', height: 80),
            const SizedBox(width: 12),
            const Text("Add Forest or Parcel"),
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
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                  child: Text(
                    "Forest",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                  child: Text(
                    "Parcel",
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
                          ? "Forest name"
                          : "Parcel name",
                      prefixIcon: Icon(
                        mode == PolygonMode.forest ? Icons.forest : Icons.map,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (mode == PolygonMode.forest)
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 15),

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
                        label: const Text("Undo"),
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
                        label: const Text("Clear"),
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
                        label: const Text("Save"),
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
                          initialCenter: LatLng(37.2, 10.12),
                          initialZoom: 13,
                          onTap: (tapPosition, point) => addPoint(point),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          ),
                          if (points.length >= 3)
                            PolygonLayer(
                              polygons: [
                                Polygon(
                                  points: points,
                                  color: mode == PolygonMode.forest
                                      ? Colors.green.withOpacity(0.4)
                                      : Colors.orange.withOpacity(0.4),
                                  borderColor: mode == PolygonMode.forest
                                      ? Colors.green
                                      : Colors.orange,
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
