import 'dart:typed_data';
import 'package:authproject/features/Admin/services/parcelle_service.dart';
import 'package:authproject/features/Agent/models/incident.dart';
import 'package:authproject/features/Agent/services/incident_service.dart';
import 'package:authproject/features/Agent/ui_components/successDialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:authproject/features/Auth/services/auth_service.dart';

class Upload extends StatefulWidget {
  const Upload({super.key});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  Map<String, dynamic>? userData;
  String? error;

  final storage = FlutterSecureStorage();

  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _regionController = TextEditingController();

  
  List<String> incidentTypes = [
    "Fire",
    "Illegal Logging",
    "Pest Outbreak",
    "Flood",
    "Pollution",
    "Human Activity",
    "Animal Attack",
    "Theft",
    "Vandalism",
    "Disease",
    "Landslide",
    "Drought",
    "Unauthorized Grazing",
    "Storm",
    "Other",
  ];

  String? selectedType;

  final _formKey = GlobalKey<FormState>();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final AuthService authService = AuthService();
  final IncidentService incidentService = IncidentService();
  final ParcelService parcelService = ParcelService();

  bool? isAssigned;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final result = await authService.getCurrentUser();
    if (result['success']) {
      setState(() => userData = result['data']);

      final assigned = await incidentService.checkAssignedParcelle(
        userData!['id'],
      );
      setState(() => isAssigned = assigned["assigned"]);
    } else {
      setState(() => error = result['message']);
    }
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("Location services are disabled.");

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  Future<void> submitIncident() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      Position position = await getCurrentLocation();

      final parcelleResult = await incidentService.checkAssignedParcelle(
        userData!['id'],
      );
      final parcelleId = parcelleResult['parcelle']?['id'];

      final parcelleDetails = await parcelService.getParcelById(parcelleId);

      if (parcelleDetails.forestId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Parcelle is not linked to a forest.")),
        );
        return;
      }

      final incident = Incident(
        description: _descriptionController.text,
        type: selectedType!, 
        location: _locationController.text,
        region: _regionController.text,
        latitude: position.latitude,
        longitude: position.longitude,
        forestId: parcelleDetails.forestId,
      );

      final success =
          await incidentService.submitIncident(incident, _imageFile!);

      if (success) {
        showSuccessDialog(context);
        _formKey.currentState!.reset();
        setState(() {
          _imageFile = null;
          selectedType = null; // ✅ reset
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit incident")),
        );
      }
    }
  }

  void showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(title: const Text("Upload"), centerTitle: true),
        body: userData == null
            ? Center(
                child: error != null
                    ? Text(error!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 16))
                    : const CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        "Create an Incident",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? "Required" : null,
                            ),
                            const SizedBox(height: 16),

                            
                            DropdownButtonFormField<String>(
                              value: selectedType,
                              decoration: InputDecoration(
                                labelText: 'Type',
                                prefixIcon: const Icon(Icons.category),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: incidentTypes
                                  .map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => selectedType = value),
                              validator: (value) =>
                                  value == null ? "Type is required" : null,
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Location',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? "Required" : null,
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _regionController,
                              decoration: const InputDecoration(
                                labelText: 'Region',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? "Required" : null,
                            ),

                            const SizedBox(height: 24),

                            /// Image
                            _imageFile == null
                                ? TextButton.icon(
                                    onPressed: showImageSourcePicker,
                                    icon: const Icon(Icons.image),
                                    label: const Text("Pick Image"),
                                  )
                                : FutureBuilder(
                                    future: _imageFile!.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data as Uint8List,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      return const CircularProgressIndicator();
                                    },
                                  ),

                            const SizedBox(height: 24),

                            if (isAssigned == false)
                              const Text(
                                "You are not assigned to a parcelle",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),

                            ElevatedButton(
                              onPressed: (isAssigned ?? false)
                                  ? submitIncident
                                  : null,
                              child: const Text("Submit Incident"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}