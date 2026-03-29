import 'dart:typed_data';
import 'package:authproject/features/Agent/models/incident.dart';
import 'package:authproject/features/Agent/services/incident_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import '../../../config.dart' as config;
import 'package:authproject/features/Auth/services/auth_service.dart';

class Upload extends StatefulWidget {
  const Upload({super.key});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  Map<String, dynamic>? userData;
  String? error;

  final String baseUrl = config.baseUrl;

  final storage = FlutterSecureStorage();

  final _descriptionController = TextEditingController();
  final _typeController = TextEditingController();
  final _locationController = TextEditingController();
  final _regionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final AuthService authService = AuthService();
  final IncidentService incidentService = IncidentService();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

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

  void loadUser() async {
    final result = await authService.getCurrentUser();
    if (result['success']) {
      setState(() => userData = result['data']);
    } else {
      setState(() => error = result['message']);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> submitIncident() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      Position position;
      try {
        position = await getCurrentLocation();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Could not get location: $e")));
        return;
      }

      final incident = Incident(
        description: _descriptionController.text,
        type: _typeController.text,
        location: _locationController.text,
        region: _regionController.text,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final success = await incidentService.submitIncident(
        incident,
        _imageFile!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Incident submitted successfully")),
        );
        _formKey.currentState!.reset();
        setState(() {
          _imageFile = null;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to submit incident")));
      }
    }
  }

  void logout() async {
    await authService.logout();
    if (!mounted) return;

    context.go('/');
  }

  void showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("Upload")],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: userData != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 20),

                            Text(
                              "Upload",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 20),

                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Username: ${userData!['username']}"),
                                    SizedBox(height: 8),
                                    Text("Email: ${userData!['email']}"),
                                    SizedBox(height: 8),
                                    Text("Age: ${userData!['age']}"),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 30),

                            ElevatedButton(
                              onPressed: logout,
                              child: Text("Logout"),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Create an Incident",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Description',
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? "Required" : null,
                            ),
                            TextFormField(
                              controller: _typeController,
                              decoration: InputDecoration(labelText: 'Type'),
                              validator: (value) =>
                                  value!.isEmpty ? "Required" : null,
                            ),
                            TextFormField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: 'Location',
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? "Required" : null,
                            ),
                            TextFormField(
                              controller: _regionController,
                              decoration: InputDecoration(labelText: 'Region'),
                              validator: (value) =>
                                  value!.isEmpty ? "Required" : null,
                            ),
                            SizedBox(height: 10),
                            _imageFile == null
                                ? TextButton.icon(
                                    onPressed: showImageSourcePicker,
                                    icon: Icon(Icons.image),
                                    label: Text("Pick Image"),
                                  )
                                : FutureBuilder(
                                    future: _imageFile!.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.done &&
                                          snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data as Uint8List,
                                          height: 150,
                                        );
                                      } else {
                                        return CircularProgressIndicator();
                                      }
                                    },
                                  ),

                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: submitIncident,
                              child: Text("Submit Incident"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : error != null
                ? Text(error!, style: TextStyle(color: Colors.red))
                : CircularProgressIndicator(),
          ),
        ),
      ),
      onWillPop: () async => false,
    );
  }
}
