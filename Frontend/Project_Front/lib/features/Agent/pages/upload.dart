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
import 'package:exif/exif.dart';
import 'dart:io';
import 'package:authproject/features/Auth/services/auth_service.dart';

import 'package:authproject/l10n/app_localizations.dart';
import 'package:authproject/main.dart';

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

  final _formKey = GlobalKey<FormState>();
  XFile? _imageFile;
  ImageSource? _imageSource;
  final ImagePicker _picker = ImagePicker();
  final AuthService authService = AuthService();
  final IncidentService incidentService = IncidentService();
  final ParcelService parcelService = ParcelService();

  bool? isAssigned;
  String? selectedRegion;
  String? selectedType;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  List<String> tunisianStates = [
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
      setState(() {
        _imageFile = pickedFile;
        _imageSource = source;
      });
    }
  }

  Future<void> submitIncident() async {
    final t = AppLocalizations.of(context)!;

    if (_formKey.currentState!.validate() && _imageFile != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      double? lat;
      double? lon;

      if (_imageSource == ImageSource.camera) {
        try {
          final position = await getCurrentLocation();
          lat = position.latitude;
          lon = position.longitude;
        } catch (e) {
          Navigator.pop(context); // Close the loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${t.agent_failed_get_loc_message} $e")),
          );
          return;
        }
      }

      if (_imageSource == ImageSource.gallery) {
        try {
          final fileBytes = await _imageFile!.readAsBytes();
          final tags = await readExifFromBytes(fileBytes);
          if (tags.containsKey('GPS GPSLatitude') &&
              tags.containsKey('GPS GPSLatitudeRef') &&
              tags.containsKey('GPS GPSLongitude') &&
              tags.containsKey('GPS GPSLongitudeRef')) {
            lat = _convertToDecimal(
              tags['GPS GPSLatitude']!.values.toList(),
              tags['GPS GPSLatitudeRef']!.printable,
            );
            lon = _convertToDecimal(
              tags['GPS GPSLongitude']!.values.toList(),
              tags['GPS GPSLongitudeRef']!.printable,
            );
          }
        } catch (e) {
          print("Failed to read EXIF data: $e");
        }

        if (lat == null || lon == null) {
          Navigator.pop(context); // Close the loading dialog
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.agent_failed_loc_message)));
          return;
        }
      }

      final incident = Incident(
        description: _descriptionController.text,
        type: selectedType!,
        location: _locationController.text,
        region: selectedRegion!,
        latitude: lat!,
        longitude: lon!,
      );

      final success = await incidentService.submitIncident(
        incident,
        _imageFile!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.agent_success_message),
            backgroundColor: const Color.fromARGB(255, 24, 49, 25),
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          _imageFile = null;
          _imageSource = null;
          selectedType = null; // reset
          selectedRegion = null; // reset
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.agent_failed_message)));
      }
    }
  }

  double _convertToDecimal(List values, String ref) {
    double toDouble(value) {
      if (value is num) return value.toDouble();
      if (value is Ratio) return value.numerator / value.denominator;
      return 0.0;
    }

    final deg = toDouble(values[0]);
    final min = toDouble(values[1]);
    final sec = toDouble(values[2]);

    double decimal = deg + (min / 60) + (sec / 3600);
    if (ref == 'S' || ref == 'W') decimal = -decimal;

    return decimal;
  }

  void showImageSourcePicker() {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(t.incident_take_photo),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(t.incident_choose_gallery),
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
    final t = AppLocalizations.of(context)!;

    List<String> incidentTypeKeys = [
      'Fire',
      'Illegal Logging',
      'Disease',
      'Artifact Theft',
      'Grazing',
      'Pollution',
      'Trash Dumping',
      'Water Contamination',
      'Other',
    ];

    List<String> incidentTypes = [
      t.incident_fire,
      t.incident_illegal_logging,
      t.incident_disease,
      t.incident_artifact_theft,
      t.incident_grazing,
      t.incident_pollution,
      t.incident_trash_dumping,
      t.incident_water_contamination,
      t.incident_other,
    ];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(t.incident_upload),

          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.language),

              onSelected: (value) {
                switch (value) {
                  case 'en':
                    (mainAppKey.currentState)?.setLocale(
                      const Locale('en', 'US'),
                    );
                    break;

                  case 'fr':
                    (mainAppKey.currentState)?.setLocale(
                      const Locale('fr', 'FR'),
                    );
                    break;

                  case 'ar':
                    (mainAppKey.currentState)?.setLocale(
                      const Locale('ar', 'AR'),
                    );
                    break;
                }
              },

              itemBuilder: (context) => [
                const PopupMenuItem(value: 'en', child: Text("English")),

                const PopupMenuItem(value: 'fr', child: Text("Français")),

                const PopupMenuItem(value: 'ar', child: Text("العربية")),
              ],
            ),
          ],
        ),
        body: userData == null
            ? Center(
                child: error != null
                    ? Text(
                        error!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      )
                    : const CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        t.incident_create_title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: t.admin_description,
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? "Required" : null,
                            ),
                            const SizedBox(height: 16),

                            DropdownButtonFormField<String>(
                              value: selectedType,
                              decoration: InputDecoration(
                                labelText: t.admin_type,
                                prefixIcon: const Icon(Icons.category),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: incidentTypeKeys
                                  .map(
                                    (key) => DropdownMenuItem(
                                      value: key,
                                      child: Text(
                                        incidentTypes[incidentTypeKeys.indexOf(
                                          key,
                                        )],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => selectedType = value),
                              validator: (value) =>
                                  value == null ? "Type is required" : null,
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: t.incidents_location,
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? "Required" : null,
                            ),

                            const SizedBox(height: 16),

                            DropdownButtonFormField<String>(
                              value: selectedRegion,
                              decoration: InputDecoration(
                                labelText: t.admin_region,
                                prefixIcon: const Icon(Icons.map),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: tunisianStates
                                  .map(
                                    (region) => DropdownMenuItem(
                                      value: region,
                                      child: Text(region),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => selectedRegion = value),
                              validator: (value) =>
                                  value == null ? "Region is required" : null,
                            ),

                            const SizedBox(height: 24),

                            /// Image
                            _imageFile == null
                                ? TextButton.icon(
                                    onPressed: showImageSourcePicker,
                                    icon: const Icon(Icons.image),
                                    label: Text(t.incident_pick_image),
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

                            Text(t.incident_camera_location),

                            const SizedBox(height: 24),

                            if (isAssigned == false)
                              Text(
                                t.incident_not_assigned,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                            ElevatedButton(
                              onPressed: (isAssigned ?? false)
                                  ? submitIncident
                                  : null,
                              child: Text(t.incident_submit),
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
