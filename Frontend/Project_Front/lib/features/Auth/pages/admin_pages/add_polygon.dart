import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:authproject/features/Auth/models/coordinates.dart';
import 'package:authproject/features/Auth/models/forest_model.dart';
import 'package:authproject/features/Auth/models/parcelle_model.dart';
import 'package:authproject/features/Auth/services/forest_service.dart';
import 'package:authproject/features/Auth/services/parcelle_service.dart';

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
          ParcelCreate(
            name: nameController.text,
            description: descriptionController.text,
            boundary: coords,
          ),
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
      appBar: AppBar(title: const Text("Draw Forest/Parcels")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ToggleButtons(
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
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Forest"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Parcel"),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: mode == PolygonMode.forest
                        ? "Forest name"
                        : "Parcel name",
                  ),
                ),

                SizedBox(height: 20),

                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                constraints: const BoxConstraints(maxWidth: 1000),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: LatLng(36.8, 10.18),
                        initialZoom: 13,
                        onTap: (tapPosition, point) {
                          addPoint(point);
                        },
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

                    Positioned(
                      right: 15,
                      bottom: 20,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            heroTag: "zoomIn",
                            mini: true,
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
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 5),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: undoPoint, child: const Text("Undo")),

                ElevatedButton(
                  onPressed: clearPolygon,
                  child: const Text("Clear"),
                ),

                ElevatedButton(
                  onPressed: savePolygon,
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
