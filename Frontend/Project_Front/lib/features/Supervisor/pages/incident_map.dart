import 'package:authproject/features/Admin/models/forest_model.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:authproject/features/Supervisor/models/incidentOut.dart';
import 'package:authproject/features/Supervisor/services/supervisor_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:authproject/features/Supervisor/ui_components/incident_details.dart';

class IncidentMap extends StatefulWidget {
  const IncidentMap({super.key});

  @override
  State<IncidentMap> createState() => _IncidentMapState();
}

class _IncidentMapState extends State<IncidentMap> {
  AuthService authService = AuthService();
  Map<String, dynamic>? userData;
  String? error;
  SupervisorServices supervisorServices = SupervisorServices();
  List<Forest>? forests;
  List<IncidentOut>? incidentData;
  final MapController _mapController = MapController();

  final northTunisiaBounds = LatLngBounds(
    LatLng(30.0, 7.0), // Southwest corner
    LatLng(37.4, 12.0), // Northeast corner
  );

  Future<void> initData() async {
    final result = await authService.getCurrentUser();
    if (!result['success']) {
      setState(() => error = result['message']);
      return;
    }

    final user = result['data'];
    final supervisorId = user['id'];

    try {
      final fetchedForests = await supervisorServices.getforestsbySupervisorId(
        supervisorId,
      );
      if (fetchedForests.isEmpty) {
        setState(() => error = 'No forests assigned to this supervisor.');
        return;
      }

      final forestIds = fetchedForests.map((f) => f.id).toList();
      final incidents = await supervisorServices.fetchIncidentsByForestids(
        forestIds,
      );
      setState(() {
        userData = user;
        forests = fetchedForests;
        incidentData = incidents;
      });
      print('User Data: $userData');
      print('Forests: $forests');
      print('Incident Data: $incidentData');
    } catch (e) {
      setState(() => error = 'Failed to fetch forests: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    print('IncidentMap initState called');
    initData();
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'not_accepted':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<Marker> _buildIncidentMarkers() {
    if (incidentData == null) {
      return [];
    }
    final incidents = incidentData!;
    return incidents
        .map((incident) {
          final lat = incident.latitude;
          final lng = incident.longitude;

          if (lat == 0.0 && lng == 0.0) {
            return null; // Skip incidents without valid coordinates
          }

          return Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      padding: EdgeInsets.all(16),
                      child: buildIncidentDetails(context, incident, initData),
                    );
                  },
                );
              },
              child: Icon(
                Icons.location_on,
                color: _getStatusColor(incident.status),
              ),
            ),
          );
        })
        .whereType<Marker>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter = incidentData != null && incidentData!.isNotEmpty
        ? LatLng(incidentData!.first.latitude, incidentData!.first.longitude)
        : LatLng(36.8, 10.18);
    return Scaffold(
      appBar: AppBar(title: const Text('Incident Map')),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: northTunisiaBounds,
                  padding: const EdgeInsets.all(16),
                ),
                cameraConstraint: CameraConstraint.contain(
                  bounds: northTunisiaBounds,
                ),
                minZoom: 8.5,
                maxZoom: 18,
                initialCenter: mapCenter,
                initialZoom: 10,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: _buildIncidentMarkers()),
              ],
            ),
          ),

          Positioned(
            right: 16,
            bottom: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoom_in",
                  mini: true,
                  backgroundColor: Colors.green,
                  onPressed: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  ),
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoom_out",
                  mini: true,
                  backgroundColor: Colors.red,
                  onPressed: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  ),
                  child: const Icon(Icons.zoom_out),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
