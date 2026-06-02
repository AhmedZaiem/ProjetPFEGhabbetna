import 'package:authproject/features/Admin/models/forest_model.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:authproject/features/Supervisor/models/incidentOut.dart';
import 'package:authproject/features/Supervisor/models/parcelleWithAgent.dart';
import 'package:authproject/features/Supervisor/services/supervisor_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:authproject/features/Supervisor/ui_components/incident_details.dart';
import 'package:authproject/l10n/app_localizations.dart';

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
  List<Parcellewithagent>? parcelles;
  Parcellewithagent? hoveredParcelle;
  final MapController _mapController = MapController();

  final northTunisiaBounds = LatLngBounds(
    LatLng(30.0, 7.0),
    LatLng(37.4, 12.0),
  );

  final rasjbal_center = LatLng(37.2, 9.94);

  @override
  void initState() {
    super.initState();
    initData();
  }

  bool _isPointInsidePolygon(LatLng point, List<LatLng> polygon) {
    bool inside = false;

    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;

      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;

      final intersect =
          ((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude <
              (xj - xi) * (point.latitude - yi) / (yj - yi) + xi);

      if (intersect) {
        inside = !inside;
      }
    }

    return inside;
  }

  void _handleParcelHover(LatLng point) {
    for (final parcelle in parcelles ?? []) {
      final polygonPoints = parcelle.boundary
          .map<LatLng>((c) => LatLng(c.lat, c.lng))
          .toList();

      if (_isPointInsidePolygon(point, polygonPoints)) {
        if (hoveredParcelle?.id != parcelle.id) {
          setState(() => hoveredParcelle = parcelle);
        }
        return;
      }
    }

    if (hoveredParcelle != null) {
      setState(() => hoveredParcelle = null);
    }
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

      final fetchedParcelles = await supervisorServices.getParcellesByForestIds(
        forestIds,
      );

      setState(() {
        userData = user;
        forests = fetchedForests;
        incidentData = incidents;
        parcelles = fetchedParcelles;
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

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
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
              child: Container(
                decoration: BoxDecoration(
                  color: _getStatusColor(incident.status),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 2),
                ),
                padding: EdgeInsets.all(8),
                child: Icon(Icons.warning, color: Colors.white, size: 18),
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final mapCenter = incidentData != null && incidentData!.isNotEmpty
        ? LatLng(incidentData!.first.latitude, incidentData!.first.longitude)
        : LatLng(36.8, 10.18);
    return Scaffold(
      appBar: AppBar(title: Text(t.supervisor_incident_map)),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                cameraConstraint: CameraConstraint.contain(
                  bounds: northTunisiaBounds,
                ),
                onPointerHover: (event, point) {
                  _handleParcelHover(point);
                },
                minZoom: 8.5,
                maxZoom: 18,
                initialCenter: rasjbal_center,
                initialZoom: 13.5,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(markers: _buildIncidentMarkers()),
                PolygonLayer(
                  polygons: (forests ?? []).map((forest) {
                    return Polygon(
                      points: forest.boundary
                          .map((c) => LatLng(c.lat, c.lng))
                          .toList(),
                      color: const Color.fromARGB(
                        255,
                        251,
                        2,
                        2,
                      ).withOpacity(0.2),
                      borderColor: const Color.fromARGB(255, 255, 3, 3),
                      borderStrokeWidth: 2,
                    );
                  }).toList(),
                ),
                PolygonLayer(
                  polygons: (parcelles ?? []).map((parcelle) {
                    return Polygon(
                      points: parcelle.boundary
                          .map((c) => LatLng(c.lat, c.lng))
                          .toList(),
                      color: const Color.fromARGB(
                        255,
                        251,
                        247,
                        27,
                      ).withOpacity(0.15),
                      borderColor: const Color.fromARGB(255, 240, 230, 55),
                      borderStrokeWidth: 2,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          Positioned(
            right: 16,
            bottom: 20,
            child: Column(
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
              ],
            ),
          ),

          Positioned(
            left: 16,
            bottom: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legendItem(Colors.green, t.accepted_incident),
                  _legendItem(Colors.orange, t.pending_incident),
                  _legendItem(Colors.red, t.not_accepted_incident),
                ],
              ),
            ),
          ),

          if (hoveredParcelle != null)
            Positioned(
              top: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hoveredParcelle!.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${t.admin_name}: ${hoveredParcelle!.agent?.name ?? 'No agent assigned'}",
                      ),
                      Text(
                        "${t.tel}: ${hoveredParcelle!.agent?.tel ?? 'No phone number available'}",
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
