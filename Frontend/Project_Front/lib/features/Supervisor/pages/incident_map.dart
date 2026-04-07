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
  SupervisorServices supervisorServices = SupervisorServices();
  Map<String, dynamic>? userData;
  String? error;
  List<Forest>? forests;
  List<IncidentOut>? incidentData;
  final MapController _mapController = MapController();

  final northTunisiaBounds = LatLngBounds(
    LatLng(30.0, 7.0),
    LatLng(37.4, 12.0),
  );

  @override
  void initState() {
    super.initState();
    initData();
  }

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
    } catch (e) {
      setState(() => error = 'Failed to fetch forests: $e');
    }
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
    if (incidentData == null) return [];
    return incidentData!
        .where((i) => i.latitude != 0.0 && i.longitude != 0.0)
        .map(
          (incident) => Marker(
            point: LatLng(incident.latitude, incident.longitude),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.all(16),
                  child: buildIncidentDetails(context, incident, initData),
                ),
              ),
              child: Icon(
                Icons.location_on,
                color: _getStatusColor(incident.status),
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter = incidentData != null && incidentData!.isNotEmpty
        ? LatLng(incidentData!.first.latitude, incidentData!.first.longitude)
        : LatLng(36.8, 10.18);

    return Scaffold(
      appBar: AppBar(title: const Text('Incident Map')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            /// Left: Buttons
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FloatingActionButton(
                  heroTag: "zoomIn",
                  mini: true,
                  backgroundColor: Colors.green,
                  onPressed: () => _mapController.move(
                    _mapController.center,
                    _mapController.zoom + 1,
                  ),
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoomOut",
                  mini: true,
                  backgroundColor: Colors.red,
                  onPressed: () => _mapController.move(
                    _mapController.center,
                    _mapController.zoom - 1,
                  ),
                  child: const Icon(Icons.zoom_out),
                ),
                const SizedBox(height: 20),
                // Add more buttons here if needed
              ],
            ),

            const SizedBox(width: 15),

            /// Right: Map
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: 10,
                  minZoom: 8.5,
                  maxZoom: 18,
                  cameraConstraint: CameraConstraint.contain(
                    bounds: northTunisiaBounds,
                  ),
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
          ],
        ),
      ),
    );
  }
}
